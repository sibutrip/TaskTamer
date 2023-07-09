//
//  Task.swift
//  ADHDBrain
//
//  Created by Cory Tripathy on 4/29/23.
//

import Foundation

struct TaskItem: Identifiable, Equatable, Codable {
    let id: UUID
    var eventID: String
    let name: String
    var sortStatus: SortStatus = .unsorted
    var startDate: Date?
    var endDate: Date?
    var scheduleDescription: String {
        switch sortStatus {
        case .sorted(_):
            guard let startDate = startDate, let endDate = endDate else { return "" }
            let daysInWeek = Calendar.current.weekdaySymbols.count
            let oneWeekForward = Calendar.current.date(byAdding: .day, value: daysInWeek, to: DateComponents.midnight.date!)!
            
            if DateComponents(calendar: Calendar.autoupdatingCurrent, timeZone: .autoupdatingCurrent, year: Calendar.autoupdatingCurrent.component(.year, from: Date()), month: Calendar.autoupdatingCurrent.component(.month, from: Date()), day: Calendar.autoupdatingCurrent.component(.day, from: Date())) == DateComponents(calendar: Calendar.autoupdatingCurrent, timeZone: .autoupdatingCurrent, year: Calendar.autoupdatingCurrent.component(.year, from: startDate), month: Calendar.autoupdatingCurrent.component(.month, from: startDate), day: Calendar.autoupdatingCurrent.component(.day, from: startDate)) {
                return "Today, \(startDate.formatted(date: .omitted, time: .shortened)) to \(endDate.formatted(date: .omitted, time: .shortened))"
            } else if DateComponents(calendar: Calendar.autoupdatingCurrent, timeZone: .autoupdatingCurrent, year: Calendar.autoupdatingCurrent.component(.year, from: Date()), month: Calendar.autoupdatingCurrent.component(.month, from: Date()), day: Calendar.autoupdatingCurrent.component(.day, from: Date())) == DateComponents(calendar: Calendar.autoupdatingCurrent, timeZone: .autoupdatingCurrent, year: Calendar.autoupdatingCurrent.component(.year, from: Date()), month: Calendar.autoupdatingCurrent.component(.month, from: Date()), day: Calendar.autoupdatingCurrent.component(.day, from: startDate) - 1) {
                return "Tomorrow, \(startDate.formatted(date: .omitted, time: .shortened)) to \(endDate.formatted(date: .omitted, time: .shortened))"
            } else if startDate < oneWeekForward {
                if let weekday = startDate.weekday {
                    return "\(weekday), \(startDate.formatted(date: .omitted, time: .shortened)) to \(endDate.formatted(date: .omitted, time: .shortened))"
                }
                fallthrough
            } else {
                return "\(startDate.formatted(date:.abbreviated, time: .shortened)) to \(endDate.formatted(date: .omitted, time: .shortened))"
            }
        case .skipped(_):
            return "Skipped until \(startDate?.formatted(date:.abbreviated, time: .omitted) ?? "")"
        case .unsorted:
            return "Unsorted"
        case .previous:
            return "Previous"
        }
    }
    
    var duration: Int? {
        guard let startDate = self.startDate, let endDate = self.endDate else { return nil }
        return Int(startDate.distance(to: endDate))
    }
    
    init(name: String) {
        id = UUID()
        eventID = ""
        self.name = name
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(UUID.self, forKey: .id)
        self.eventID = try! container.decode(String.self, forKey: .eventID)
        self.name = try container.decode(String.self, forKey: .name)
        self.startDate = try container.decodeIfPresent(Date.self, forKey: .startDate)
        self.endDate = try container.decodeIfPresent(Date.self, forKey: .endDate)
        if let endDate = endDate {
            if Date() > endDate {
                self.sortStatus = .previous
            } else {
                self.sortStatus = try container.decode(SortStatus.self, forKey: .sortStatus)
            }
        }
    }
    
    mutating func sort(duration: TimeInterval, at time: TimeSelection, within tasks: [TaskItem], vm: ViewModel, isRescheduling: Bool = false) async throws {
        switch time {
        case .morning, .afternoon, .evening:
            let eventService = EventService.shared
            let taskToReschedule = isRescheduling ? self : nil
            let scheduledDate = try await eventService.selectDate(duration: duration, from: time, within: tasks, vm: vm, rescheduling: taskToReschedule)
            guard let scheduledDate = scheduledDate else {
                throw EventServiceError.scheduleFull
            }
            (self.startDate, self.endDate) = scheduledDate
//            print(startDate?.formatted(),endDate?.formatted())
            self.sortStatus = .sorted(time)
            try await eventService.scheduleEvent(for: &self)
        case .skip1:
            self.sortStatus = .skipped(time)
            self.startDate = Calendar.current.date(byAdding: .day, value: 1, to: DateComponents.midnight.date!)!
            self.endDate = Calendar.current.date(byAdding: .day, value: 1, to: DateComponents.midnight.date!)!
        case .skip3:
            self.sortStatus = .skipped(time)
            self.startDate = Calendar.current.date(byAdding: .day, value: 3, to: DateComponents.midnight.date!)!
            self.endDate = Calendar.current.date(byAdding: .day, value: 3, to: DateComponents.midnight.date!)!
        case .skip7:
            self.sortStatus = .skipped(time)
            self.startDate = Calendar.current.date(byAdding: .day, value: 7, to: DateComponents.midnight.date!)!
            self.endDate = Calendar.current.date(byAdding: .day, value: 7, to: DateComponents.midnight.date!)!
        case .noneSelected:
            return
        case .other:
            return
        }
        return
    }
    
    mutating private func checkSkipDate() {
        guard let skipUntilDate = self.startDate else {
            return
        }
        if Date() > skipUntilDate {
            self.sortStatus = .unsorted
            self.startDate = nil
        }
    }
}
