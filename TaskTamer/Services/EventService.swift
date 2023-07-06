//
//  EventService.swift
//  ADHDBrain
//
//  Created by Cory Tripathy on 5/3/23.
//

import Foundation
import EventKit
import SwiftUI

enum DeleteFail: Error {
    case noDate
}

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
        if try await eventStore.requestAccess(to: .event) {
            
            guard let startDate = task.startDate else { return }
            let event = EKEvent(eventStore: eventStore)
            event.title = task.name
            event.startDate = startDate
            event.endDate = startDate.addingTimeInterval(900)
            event.calendar = eventStore.defaultCalendarForNewEvents
            event.addAlarm(.init(absoluteDate: startDate))
            try eventStore.save(event, span: .thisEvent)
            task.eventID = event.eventIdentifier
        } else { fatalError() }
    }
    
    public func selectDate(duration: TimeInterval, from timeSelection: TimeSelection, within tasks: [TaskItem]) async -> (Date,Date)? {
        if firstTimeAddingEvent {
            guard await requestCalendarPermission() else {
                return nil
            }
            firstTimeAddingEvent = false
        }
        let availableDates = fetchAvailableDates(for: timeSelection, within: tasks)
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
    private func fetchAvailableDates(for timeSelection: TimeSelection, within tasks: [TaskItem]) -> [(Date,Date)] {
        var startDate: Date
        var endDate: Date
        var midnight = DateComponents.midnight.date!
        switch timeSelection {
        case .morning:
            startDate = DateComponents.hour(from: 8).date!
            endDate = DateComponents.hour(from: 12).date!
        case .afternoon:
            startDate = DateComponents.hour(from: 13).date!
            endDate = DateComponents.hour(from: 17).date!
        case .evening:
            startDate = DateComponents.hour(from: 17).date!
            endDate = DateComponents.hour(from: 21).date!
        default:
            return []
        }
        
        if Date() > endDate {
            startDate = startDate.addingTimeInterval(86400)
            endDate = endDate.addingTimeInterval(86400)
            midnight = midnight.addingTimeInterval(86400)
        }
        
        let predicate = eventStore.predicateForEvents(withStart: midnight, end: endDate, calendars: [eventStore.defaultCalendarForNewEvents!])
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
                print(Date.nearestQuarterHour)
                return (Date.nearestQuarterHour,endDate)
            }
            return (startDate,endDate)
        }
        .filter { $0.0 != $0.1 }
        print(freeTime)
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
