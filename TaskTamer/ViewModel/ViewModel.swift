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
    
    @AppStorage("timeBlockDuration") var timeBlockDuration = 15
    @Published var showingPreviousTaskSheet = false
    @Published var showingSettingsSheet = false

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
            try await task.sort(duration: duration, at: time, within: tasks, vm: self, isRescheduling: isRescheduling)
            var tasks = self.tasks
            tasks = tasks.filter {
                $0.id != task.id
            }
            tasks.append(task)
            self.tasks = tasks
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
                do {
                    if try eventService.deleteEvent(for: task) {
                        task.eventID = ""
                    }
                } catch {
                    print("could not delete event for unknown reason")
                }
            }
        }
        tasks = tasks.filter {
            $0.id != task.id
        }
        task.startDate = nil
        task.sortStatus = .unsorted
        tasks.append(task)
        self.tasks = tasks
    }
    
    public func deleteTask(_ task: TaskItem) throws {
        var task = task
        var tasks = self.tasks
        if let _ = task.startDate {
            do {
                if try eventService.deleteEvent(for: task) {
                    task.eventID = ""
                }
            } catch {
                print("could not delete event for unknown reason")
            }
        }
        tasks = tasks.filter {
            $0.id != task.id
        }
        self.tasks = tasks
    }
    
    /// Schedules a task at a start time with a given duration
    /// - Parameter task: TaskItem to schedule
    /// - Parameter time: the start time of the task
    /// - Parameter timeSelection: TimeSelection to schedule the event within
    /// - Parameter duration: Duration of task from start to end
    public func schedule(task: TaskItem, at time: Date? = nil, within timeSelection: TimeSelection, with duration: TimeInterval) async {
        do {
            var task = task
            
            let scheduledDate: (startDate: Date, endDate: Date)?
            if let time {
                var specifiedTimes = (startDate: time,endDate: time.addingTimeInterval(duration))
                specifiedTimes.startDate = Calendar.autoupdatingCurrent.date(byAdding: .day, value: 1, to: specifiedTimes.startDate) ?? specifiedTimes.startDate
                specifiedTimes.endDate = Calendar.autoupdatingCurrent.date(byAdding: .day, value: 1, to: specifiedTimes.endDate) ?? specifiedTimes.endDate
                scheduledDate = specifiedTimes
            } else {
                scheduledDate = try await randomValidDate(in: timeSelection, with: duration)
            }
            guard let scheduledDate else {
                throw EventServiceError.unknown
            }
            
            try await task.sort(from: scheduledDate.startDate, to: scheduledDate.endDate, at: timeSelection)
            var tasks = self.tasks
            tasks = tasks.filter {
                $0.id != task.id
            }
            tasks.append(task)
            self.tasks = tasks
        } catch {
            let eventServiceError = error as? EventServiceError
            switch eventServiceError {
            case .noPermission:
                noPermission = true
            case .scheduleFull:
                scheduleFull = true
            case .unknown:
                fatalError("an unknown issue occured")
            case .none:
                unknownError = true
            }
        }
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
    
    func randomValidDate(in timeSelection: TimeSelection, with duration: TimeInterval, rescheduling task: Scheduleable? = nil) async throws -> (startDate: Date,endDate: Date)? {
        var startDate: Date
        var endDate: Date
        switch timeSelection {
        case .morning:
            startDate = morningStartTime
            endDate = morningEndTime
        case .afternoon:
            startDate = afternoonStartTime
            endDate = afternoonEndtime
        case .evening:
            startDate = eveningStartTime
            endDate = eveningEndTime
        default:
            return nil
        }
        if Date() > endDate {
            startDate = startDate.addingTimeInterval(86400)
            endDate = endDate.addingTimeInterval(86400)
        }
        return try await eventService.selectDate(from: startDate, to: endDate, with: duration, rescheduling: task)
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
