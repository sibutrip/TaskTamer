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
    
    public func userCalendars() -> [EKCalendar] {
        return eventStore.calendars(for: .event)
    }
    
    public func remove(_ task: Scheduleable) async throws {
        guard let eventID = task.eventID else { throw EventServiceError.noPermission }
        if await requestCalendarPermission(for: .full) {
            guard let eventToReschedule = eventStore.event(withIdentifier: eventID) else {
                throw EventServiceError.noPermission
            }
            try eventStore.remove(eventToReschedule, span: .thisEvent)
        } else {
            throw EventServiceError.noPermission
        }
    }
    
//    public func deleteEvent(for task: Scheduleable) throws -> Bool {
//        guard let eventID = task.eventID else { return false }
//        let event = eventStore.event(withIdentifier: eventID)
//        if let event = event {
//            try eventStore.remove(event, span: .thisEvent)
//            return true
//        } else {
//            print("no event!")
//            return false
//        }
//    }
    
    public func updateTaskTimes(for tasks: [Scheduleable]) -> [Scheduleable] {
        return tasks.map { task in
            var task = task
            guard let eventID = task.eventID, let event = eventStore.event(withIdentifier: eventID) else { return task }
            let startDate = event.startDate
            let endDate = event.endDate
            task.startDate = startDate
            task.endDate = endDate
            return task
        }
    }
    
    public func scheduleEvent(for task: Scheduleable) async throws -> String? {
        let accessGranted = await requestCalendarPermission(for: .write)
        if accessGranted {
            guard let startDate = task.startDate, let endDate = task.endDate else { return nil }
            let event = EKEvent(eventStore: eventStore)
            event.title = task.eventTitle
            event.startDate = startDate
            let duration = Date.distance(startDate)(to: endDate)
            event.endDate = startDate.addingTimeInterval(duration)
            event.calendar = eventStore.defaultCalendarForNewEvents
            event.addAlarm(.init(absoluteDate: startDate))
            try eventStore.save(event, span: .thisEvent)
            //            task.eventID = event.eventIdentifier
            let id = event.eventIdentifier
            return id
        } else { throw EventServiceError.noPermission }
    }
    
    public func selectDate(from startDate: Date, to endDate: Date, with duration: TimeInterval, rescheduling task: Scheduleable? = nil) async throws -> (Date,Date)? {
        if firstTimeAddingEvent {
            guard await requestCalendarPermission(for: .write) else {
                throw EventServiceError.noPermission
            }
            firstTimeAddingEvent = false
        }
        
        guard let calendar = eventStore.defaultCalendarForNewEvents else { fatalError("no default cal found. let user select a calendar.")}
        let predicate = eventStore.predicateForEvents(withStart: DateComponents.midnight.date!, end: endDate, calendars: [calendar])
        var events = eventStore.events(matching: predicate)
            .filter { $0.endDate <= endDate && $0.endDate > startDate }
        //        if let task {
        //            try await reschedule(task, in: &events)
        //        }
        let freeTime = freeTime(in: events, from: startDate, to: endDate)
        let availableDates = freeTime
            .flatMap { (startTime, endTime) in
                let distance = startTime.distance(to: endTime)
                let numberOfAvailableSlots = Int(distance / duration) // rounds down
                return (0..<numberOfAvailableSlots).map { index in
                    return startTime.addingTimeInterval(TimeInterval(index) * duration)
                }
            }
        let startDate = availableDates.randomElement()
        let endDate = startDate?.addingTimeInterval(duration)
        
        guard let startDate = startDate, let endDate = endDate else { return nil }
        return (startDate,endDate)
    }
    
    private func freeTime(in events: [EKEvent], from startDate: Date, to endDate: Date) -> [(startTime: Date, endTime: Date)] {
        var freeTime: [(Date,Date)] = events.enumerated().compactMap { index, event in
            guard let eventStartTime = event.startDate, let eventEndTime = event.endDate else { return nil }
            if index == 0 {
                return (startDate,eventStartTime)
            } else if index == (events.count - 1) {
                return (eventEndTime,endDate)
            }
            let lastEvent = events[index - 1]
            return (lastEvent.endDate, event.startDate)
        }
        if freeTime.count == 1 { freeTime.append((events[0].endDate, endDate)) }
        if freeTime.isEmpty { freeTime.append((startDate,endDate)) }
        return freeTime.map { (startDate,endDate) in
            if startDate < Date.nearestQuarterHour {
                return (Date.nearestQuarterHour,endDate)
            }
            return (startDate,endDate)
        }
        .filter { $0.0 != $0.1 }
        .filter { $0.0 < $0.1 }
    }
    
    enum CalendarPermissionType { case write, full }
    
    private func requestCalendarPermission(for calendarPermissionType: CalendarPermissionType) async -> Bool {
        do {
            let store = EKEventStore.init()
            let result: Bool
            switch calendarPermissionType {
            case .write:
                if #available(iOS 17.0, *) {
                    result = try await store.requestWriteOnlyAccessToEvents()
                } else {
                    result = try await store.requestAccess(to: .event)
                }
            case .full:
                if #available(iOS 17.0, *) {
                    result = try await store.requestFullAccessToEvents()
                } else {
                    result = try await store.requestAccess(to: .event)
                }
            }
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
