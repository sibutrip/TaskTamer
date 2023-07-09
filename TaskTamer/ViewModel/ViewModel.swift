//
//  ViewModel.swift
//  ADHDBrain
//
//  Created by Cory Tripathy on 4/29/23.
//

import Foundation
import EventKit
import SwiftUI

@MainActor
class ViewModel: ObservableObject {
    
    @Published var showingPreviousTaskSheet = false
    @Published var showingSettingsSheet = false
    @AppStorage("timeBlockDuration") var timeBlockDuration = 15

    @Published var scheduleFull = false
    @Published var noPermission = false
    @Published var unknownError = false
    
    @TimeBlock("morningStart", hour: 8, minute: 0) var morningStartTime
    @TimeBlock("morningEnd", hour: 12, minute: 0) var morningEndTime
    @TimeBlock("afternoonStart", hour: 13, minute: 0) var afternoonStartTime
    @TimeBlock("afternoonEnd", hour: 17, minute: 0) var afternoonEndtime
    @TimeBlock("eveningStart", hour: 17, minute: 0) var eveningStartTime
    @TimeBlock("eveningEnd", hour: 21, minute: 0) var eveningEndTime
    
    
    let eventService: EventService
    @Saving var tasks: [TaskItem] {
        didSet {
            objectWillChange.send()
        }
    }
    var unsortedTasks: [TaskItem] {
        tasks
            .filter { $0.sortStatus == .unsorted }
            .sorted { $0.name < $1.name }
    }
    
    var previousTasks: [TaskItem] {
        tasks
            .filter { return $0.sortStatus == .previous }
            .sorted { $0.name < $1.name }
    }
    
    public func refreshTasks() {
        let tasks = eventService.updateTaskTimes(for: tasks)
        self.tasks = refreshSortStatus(for: tasks)
    }
    
    private func refreshSortStatus(for tasks: [TaskItem]) -> [TaskItem] {
        let morningStart = morningStartTime.adjustedToCurrentDay
        let morningEnd = morningEndTime.adjustedToCurrentDay
        let afternoonStart = afternoonStartTime.adjustedToCurrentDay
        let afternoonEnd = afternoonEndtime.adjustedToCurrentDay
        let eveningStart = eveningStartTime.adjustedToCurrentDay
        let eveningEnd = eveningEndTime.adjustedToCurrentDay
        
        return tasks.map { task in
            var task = task
            guard let startDate = task.startDate, let endDate = task.endDate else { return task }
            if endDate < Date() {
                task.sortStatus = .previous
                return task
            } else if task.sortStatus.case == .skipped {
                return task
            } else if startDate.adjustedToCurrentDay >= morningStart && startDate.adjustedToCurrentDay < morningEnd {
                task.sortStatus = .sorted(.morning)
            } else if startDate.adjustedToCurrentDay >= afternoonStart && startDate.adjustedToCurrentDay < afternoonEnd {
                task.sortStatus = .sorted(.afternoon)
            } else if startDate.adjustedToCurrentDay >= eveningStart && startDate.adjustedToCurrentDay < eveningEnd {
                task.sortStatus = .sorted(.evening)
            } else {
                task.sortStatus = .sorted(.other)
            }
            return task
        }
    }
    
    /// duration in minutes, returns a bool to indicate success or not
    public func sortTask(_ task: TaskItem, _ time: TimeSelection, duration: Int = 900, isRescheduling: Bool = false) async -> Bool {
        do {
            var task = task
            let duration = Double(duration * 60)
//            let duration: TimeInterval = 900 // 15 mins
            try await task.sort(duration: duration, at: time, within: tasks, vm: self, isRescheduling: isRescheduling)
            var tasks = self.tasks
            tasks = tasks.filter {
                $0.id != task.id
            }
            tasks.append(task)
            self.tasks = tasks
            DirectoryService.writeModelToDisk(tasks)
            return true
        } catch {
            let eventServiceError = error as? EventServiceError
            switch eventServiceError {
            case .noPermission:
                noPermission = true
            case .scheduleFull:
                scheduleFull = true
            case .none:
                unknownError = true
            }
            return false
        }
    }
    
    public func unscheduleTask(_ task: TaskItem) {
        var task = task
        var tasks = self.tasks
        if let _ = task.startDate {
            if task.sortStatus.sortName != "Skipped"  {
                try? eventService.deleteEvent(for: &task)
            }
        }
        tasks = tasks.filter {
            $0.id != task.id
        }
        task.startDate = nil
        task.sortStatus = .unsorted
        tasks.append(task)
        DirectoryService.writeModelToDisk(tasks)
        self.tasks = tasks
    }
    
    public func deleteTask(_ task: TaskItem) throws {
        var task = task
        var tasks = self.tasks
        if let _ = task.startDate {
            try? eventService.deleteEvent(for: &task)
        }
        tasks = tasks.filter {
            $0.id != task.id
        }
        DirectoryService.writeModelToDisk(tasks)
        self.tasks = tasks
    }
    
    public func rescheduleTask(_ task: TaskItem, _ time: TimeSelection, duration: Int = 900) async {
        if await sortTask(task, time, duration: duration, isRescheduling: true) {
            eventService.removeRescheduledEvent()
        }
    }
    
    private func initTasks() {
        let tasks: [TaskItem]? = try? DirectoryService.readModelFromDisk()
        if let tasks = tasks {
            _tasks.projectedValue = tasks.sorted { $0.name < $1.name }
        } else {
            self.tasks = []
        }
    }
    
    public func openCalendar(for task: TaskItem) async {
        guard task.sortStatus.case == .sorted else { return }
        guard let date = task.startDate, let url = URL(string: "calshow:\(date.timeIntervalSinceReferenceDate)") else {
            return
        }
        await UIApplication.shared.open(url)
    }
    
    init() {
        eventService = EventService.shared
        initTasks()
        refreshTasks()
        tasks.forEach { task in
            if task.sortStatus == .previous {
                print(task.name)
            }
        }
    }
}
