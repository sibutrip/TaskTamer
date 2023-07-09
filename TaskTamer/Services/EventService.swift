//
//  EventService.swift
//  ADHDBrain
//
//  Created by Cory Tripathy on 5/3/23.
//

import Foundation
import EventKit
import SwiftUI

class EventService {
    @AppStorage("firstTimeAddingEvent") var firstTimeAddingEvent = true
    
    private let eventStore: EKEventStore
    
    public func deleteEvent(for task: TaskItem) throws {
        let event = eventStore.event(withIdentifier: task.eventID)
        if let event = event {
            try eventStore.remove(event, span: .thisEvent)
        } else {
            print("no event!")
        }
    }
    
    public func updateTaskTimes(for tasks: [TaskItem]) -> [TaskItem] {
        return tasks.map { task in
            var task = task
            guard let event = eventStore.event(withIdentifier: task.eventID) else { return task }
            let startDate = event.startDate
            let endDate = event.endDate
            task.startDate = startDate
            task.endDate = endDate
            return task
        }
    }
    
    public func scheduleEvent(for task: inout TaskItem) async throws {
        guard let accessGranted = try? await eventStore.requestAccess(to: .event) else {
            throw EventServiceError.noPermission
        }
        if accessGranted {
            guard let startDate = task.startDate, let endDate = task.endDate else { return }
            let event = EKEvent(eventStore: eventStore)
            event.title = task.name
            event.startDate = startDate
            let duration = Date.distance(startDate)(to: endDate)
            event.endDate = startDate.addingTimeInterval(duration)
            event.calendar = eventStore.defaultCalendarForNewEvents
            event.addAlarm(.init(absoluteDate: startDate))
            try eventStore.save(event, span: .thisEvent)
            task.eventID = event.eventIdentifier
        } else { throw EventServiceError.noPermission }
    }
    
    public func selectDate(duration: TimeInterval, from timeSelection: TimeSelection, within tasks: [TaskItem], vm: ViewModel) async throws -> (Date,Date)? {
        if firstTimeAddingEvent {
            guard await requestCalendarPermission() else {
                throw EventServiceError.noPermission
            }
            firstTimeAddingEvent = false
        }
        let availableDates = try await fetchAvailableDates(for: timeSelection, within: tasks, vm: vm)
            .flatMap { (startTime, endTime) in
                let distance = startTime.distance(to: endTime)
                let numberOfAvailableSlots = Int(distance / duration) // rounds down
                return (0..<numberOfAvailableSlots).map { index in
                    return startTime.addingTimeInterval(TimeInterval(index) * duration)
                }
            }
//        availableDates.forEach { print($0.description(with: .autoupdatingCurrent)) }
        
        let startDate = availableDates.randomElement()
        let endDate = startDate?.addingTimeInterval(duration)
        
        guard let startDate = startDate, let endDate = endDate else { return nil }
        return (startDate,endDate)
    }
    
    /// returns [(start date, end date)] for free times in given TimeSelection
    @MainActor private func fetchAvailableDates(for timeSelection: TimeSelection, within tasks: [TaskItem], vm: ViewModel) throws -> [(Date,Date)] {
        var startDate: Date
        var endDate: Date
        var midnight = DateComponents.midnight.date!
        switch timeSelection {
        case .morning:
            startDate = vm.morningStartTime
            endDate = vm.morningEndTime
        case .afternoon:
            startDate = vm.afternoonStartTime
            endDate = vm.afternoonEndtime
        case .evening:
            startDate = vm.eveningStartTime
            endDate = vm.eveningEndTime
        default:
            return []
        }
        
        if Date() > endDate {
            startDate = startDate.addingTimeInterval(86400)
            endDate = endDate.addingTimeInterval(86400)
            midnight = midnight.addingTimeInterval(86400)
        }
        guard let calendar = eventStore.defaultCalendarForNewEvents else { throw EventServiceError.noPermission }
        let predicate = eventStore.predicateForEvents(withStart: midnight, end: endDate, calendars: [calendar])
        let events = eventStore.events(matching: predicate)
            .filter { $0.endDate <= endDate && $0.endDate > startDate }
        var freeTime: [(Date,Date)] = (0..<events.count).map { index in
            let event = events[index]
            if index == 0 {
                return (startDate,event.startDate)
            } else if index == (events.count - 1) {
                return (event.endDate,endDate)
            }
            let lastEvent = events[index - 1]
            return (lastEvent.endDate, event.startDate)
        }
        if freeTime.count == 1 { freeTime.append((events[0].endDate, endDate)) }
        if freeTime.isEmpty { freeTime.append((startDate,endDate)) }
        freeTime = freeTime.map { (startDate,endDate) in
            if startDate < Date.nearestQuarterHour {
                return (Date.nearestQuarterHour,endDate)
            }
            return (startDate,endDate)
        }
        .filter { $0.0 != $0.1 }
        .filter { $0.0 < $0.1}
        return freeTime
    }
    
    private func requestCalendarPermission() async -> Bool {
        do {
            let store = EKEventStore.init()
            let result = try await store.requestAccess(to: .event)
            return result
        } catch {
            return false
        }
    }
    
    init() {
        self.eventStore = EKEventStore()
    }
    
    static let shared = EventService()
}
