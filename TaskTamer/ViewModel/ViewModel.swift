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
    
    @Published var showingPreviousTaskSheet = true
    @Published var sortDidFail = false
    
    
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
        return tasks.map { task in
            var task = task
            guard let startDate = task.startDate, let _ = task.endDate else { return task }
            //            print(TaskItem.morningStartTime,TaskItem.morningEndTime)
            //            print(TaskItem.afternoonStartTime,TaskItem.afternoonEndTime)
            //            print(TaskItem.eveningStartTime,TaskItem.eveningEndTime)
            
            if task.sortStatus == .previous || task.endDate ?? Date.distantFuture < Date() {
                task.sortStatus = .previous
                return task
            } else if startDate >= TaskItem.morningStartTime && startDate < TaskItem.morningEndTime {
                task.sortStatus = .sorted(.morning)
            } else if startDate >= TaskItem.afternoonStartTime && startDate < TaskItem.afternoonEndTime {
                task.sortStatus = .sorted(.afternoon)
            } else if startDate >= TaskItem.eveningStartTime && startDate < TaskItem.eveningEndTime {
                task.sortStatus = .sorted(.evening)
            } else {
                task.sortStatus = .sorted(.other)
            }
            return task
        }
    }
    
    public func sortTask(_ task: TaskItem, _ time: TimeSelection) async throws {
        var task = task
        let duration: TimeInterval = 900 // 15 mins
        try await task.sort(duration: duration, at: time, within: tasks)
        var tasks = self.tasks
        tasks = tasks.filter {
            $0.id != task.id
        }
        tasks.append(task)
        self.tasks = tasks
        DirectoryService.writeModelToDisk(tasks)
    }
    
    public func unscheduleTask(_ task: TaskItem) {
        var task = task
        var tasks = self.tasks
        if let _ = task.startDate {
            if task.sortStatus.sortName != "Skipped"  {
                try? eventService.deleteEvent(for: task)
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
        var tasks = self.tasks
        if let _ = task.startDate {
            try? eventService.deleteEvent(for: task)
        }
        tasks = tasks.filter {
            $0.id != task.id
        }
        DirectoryService.writeModelToDisk(tasks)
        self.tasks = tasks
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
