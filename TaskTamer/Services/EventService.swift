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
    @Saving private var usedDates: [Date] {
        didSet {
            _ = usedDates.map {
                print($0.description(with: .autoupdatingCurrent))
                print($0.formatted())
            }
        }
    }
    private let eventStore: EKEventStore
    
    
    public func deleteEvent(for date: Date) throws {
        let usedDates = self.usedDates
        print(date.description(with: .autoupdatingCurrent))
        let date = usedDates.first {
            $0 == date
        }
        guard let date = date else {
            throw DeleteFail.noDate
        }
        let predicate = eventStore.predicateForEvents(withStart: date, end: date.addingTimeInterval(900), calendars: [eventStore.defaultCalendarForNewEvents!])
        let events = eventStore.events(matching: predicate)
        if events.count < 1 {
            return
        }
        let event = events[0]
        try eventStore.remove(event, span: .thisEvent)
        self.usedDates = usedDates.filter {
            $0 != date
        }
    }
    
    public func scheduleEvent(for task: TaskItem) async  {
        if firstTimeAddingEvent {
            guard await requestCalendarPermission() else {
                return
            }
            firstTimeAddingEvent = false
        }
        do {
            if try await eventStore.requestAccess(to: .event) {
                
                guard let scheduledDate = task.scheduledDate else { return }
                let event = EKEvent(eventStore: eventStore)
                event.title = task.name
                event.startDate = scheduledDate
                event.endDate = scheduledDate.addingTimeInterval(900)
                event.calendar = eventStore.defaultCalendarForNewEvents
                event.addAlarm(.init(absoluteDate: scheduledDate))
                try eventStore.save(event, span: .thisEvent)
                self.usedDates.append(scheduledDate)
                //                print(self.usedDates)
            } else { fatalError() }
        } catch {
            print("failed to save event with error : \(error.localizedDescription)")
        }
    }
    
    public func selectDate(from timeSelection: TimeSelection) -> Date? {
        let usedDates = self.usedDates
        let availableDates = fetchAvailableDates(for: timeSelection)
        let randomDate = availableDates.filter { date in
            !usedDates.contains(date)
        }.randomElement()
        guard let randomDate = randomDate else { return nil }
        return randomDate
    }
    
    private func fetchAvailableDates(for timeSelection: TimeSelection) -> [Date] {
        let cal = Calendar(identifier: .gregorian)
        let date = Date()
        let time = DateComponents(calendar: .autoupdatingCurrent, timeZone: .autoupdatingCurrent, year: cal.component(.year, from: date), month: cal.component(.month, from: date), day: cal.component(.day, from: date), hour: cal.component(.hour, from: date), minute: cal.component(.minute, from: date), second: cal.component(.second, from: date))
        let endHour: Int
        switch timeSelection {
        case .morning:
            endHour = 11
        case .afternoon:
            endHour = 16
        case .evening:
            endHour = 20
        default:
            return []
        }
        let hourDiff = (endHour - time.hour!) * 4
        let minDiff = (60 - time.minute!) / 15 // integer division
        var availableSlots = hourDiff + minDiff
        if availableSlots > 14 || availableSlots < 0 { // if the time hasnt come yet today (greater than 16), limit to 16. if it's already passed today (less than 0), set to 16
            availableSlots = 14
        }
        let dates = generateDates(for: availableSlots, during: timeSelection)
        return dates
    }
    
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
    
    private func initUsedDates() {
        let usedDates: [Date]? = try? DirectoryService.readModelFromDisk()
        if var usedDates = usedDates {
            usedDates = usedDates.filter {
                Date() < $0
            }
            self.usedDates = usedDates
        } else {
            self.usedDates = []
        }
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
        if !firstTimeAddingEvent {
            initUsedDates()
        } else {
            usedDates = []
        }
    }
    
    static let shared = EventService()
}
