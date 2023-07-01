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
    //    @Saving private var usedDates: [Date] {
    //        didSet {
    //            _ = usedDates.map {
    //                print($0.description(with: .autoupdatingCurrent))
    //                print($0.formatted())
    //            }
    //        }
    //    }
    private let eventStore: EKEventStore
    
    public func deleteEvent(for task: TaskItem) throws {
        let event = eventStore.event(withIdentifier: task.id)
        if let event = event {
            try eventStore.remove(event, span: .thisEvent)
        } else {
            print("no event!")
        }
    }
    
    
    //    public func deleteEvent(for date: Date) throws {
    //        let usedDates = self.usedDates
    //        print(date.description(with: .autoupdatingCurrent))
    //        let date = usedDates.first {
    //            $0 == date
    //        }
    //        guard let date = date else {
    ////            throw DeleteFail.noDate
    //            return
    //        }
    ////        let predicate = eventStore.
    //        let predicate = eventStore.predicateForEvents(withStart: date, end: date.addingTimeInterval(900), calendars: [eventStore.defaultCalendarForNewEvents!])
    //        let events = eventStore.events(matching: predicate)
    //        if events.count < 1 {
    //            return
    //        }
    //        let event = events[0]
    //        try eventStore.remove(event, span: .thisEvent)
    //        self.usedDates = usedDates.filter {
    //            $0 != date
    //        }
    //    }
    
    public func updateTaskTimes(for tasks: [TaskItem]) -> [TaskItem] {
        return tasks.map { task in
            var task = task
            guard let event = eventStore.event(withIdentifier: task.id) else { return task }
            let startDate = event.startDate
            let endDate = event.endDate
            task.startDate = startDate
            task.endDate = endDate
            return task
        }
    }
    
    public func scheduleEvent(for task: inout TaskItem) async throws {
        if firstTimeAddingEvent {
            guard await requestCalendarPermission() else {
                return
            }
            firstTimeAddingEvent = false
        }
        if try await eventStore.requestAccess(to: .event) {
            
            guard let startDate = task.startDate else { return }
            let event = EKEvent(eventStore: eventStore)
            event.title = task.name
            event.startDate = startDate
            event.endDate = startDate.addingTimeInterval(900)
            event.calendar = eventStore.defaultCalendarForNewEvents
            event.addAlarm(.init(absoluteDate: startDate))
            try eventStore.save(event, span: .thisEvent)
            task.id = event.eventIdentifier
        } else { fatalError() }
    }
    
    public func selectDate(duration: TimeInterval, from timeSelection: TimeSelection, within tasks: [TaskItem]) -> (Date,Date)? {
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
            .filter { $0.endDate < endDate && $0.endDate > startDate }
        if events.isEmpty { return [(startDate,endDate)] }
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
        return freeTime
    }
    
    //    private func fetchAvailableDates(for timeSelection: TimeSelection, within: [TaskItem]) -> [Date] {
    //            let cal = Calendar(identifier: .gregorian)
    //            let date = Date()
    //            let time = DateComponents(calendar: .autoupdatingCurrent, timeZone: .autoupdatingCurrent, year: cal.component(.year, from: date), month: cal.component(.month, from: date), day: cal.component(.day, from: date), hour: cal.component(.hour, from: date), minute: cal.component(.minute, from: date), second: cal.component(.second, from: date))
    //            let endHour: Int
    //            switch timeSelection {
    //            case .morning:
    //                endHour = 11
    //            case .afternoon:
    //                endHour = 16
    //            case .evening:
    //                endHour = 20
    //            default:
    //                return []
    //            }
    //            let hourDiff = (endHour - time.hour!) * 4
    //            let minDiff = (60 - time.minute!) / 15 // integer division
    //            var availableSlots = hourDiff + minDiff
    //            if availableSlots > 14 || availableSlots < 0 { // if the time hasnt come yet today (greater than 16), limit to 16. if it's already passed today (less than 0), set to 16
    //                availableSlots = 14
    //            }
    //            let dates = generateDates(for: availableSlots, during: timeSelection)
    //            return dates
    //        }
    
    private func generateDates(for availableSlots: Int, during timeSelection: TimeSelection) -> [Date] {
        let cal = Calendar.current
        var dates = [Date]()
        var availableSlots = availableSlots
        var mins = 45
        var hour: Int
        switch timeSelection {
        case .morning:
            hour = 11
        case .afternoon:
            hour = 16
        case .evening:
            hour = 20
        default:
            return []
        }
        
        while availableSlots > 0 {
            let date = (cal.nextDate(after: Date(), matching: DateComponents(calendar: .autoupdatingCurrent, timeZone: .autoupdatingCurrent, hour: hour, minute: mins), matchingPolicy: .nextTime))
            
            dates.append(date!)
            
            availableSlots -= 1
            if mins == 0 {
                mins = 45
                hour -= 1
            } else {
                mins -= 15
            }
        }
        return dates
    }
    
    //    private func initUsedDates() {
    //        let usedDates: [Date]? = try? DirectoryService.readModelFromDisk()
    //        if var usedDates = usedDates {
    //            usedDates = usedDates.filter {
    //                Date() < $0
    //            }
    //            self.usedDates = usedDates
    //        } else {
    //            self.usedDates = []
    //        }
    //    }
    
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
        //        if !firstTimeAddingEvent {
        //            initUsedDates()
        //        } else {
        //            usedDates = []
        //        }
    }
    
    static let shared = EventService()
}
