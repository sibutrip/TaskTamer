//
//  Task.swift
//  ADHDBrain
//
//  Created by Cory Tripathy on 4/29/23.
//

import Foundation

struct TaskItem: Identifiable, Equatable, Codable, Scheduleable {
    let id: UUID
    var eventID: String?
    var eventTitle: String { name }
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
    
    init(name: String) {
        id = UUID()
        self.name = name
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(UUID.self, forKey: .id)
        self.eventID = try container.decodeIfPresent(String.self, forKey: .eventID)
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
    
    /// Sorts task within a TimeSelection from start to end time
    /// - Parameter startTime: the start time of the task
    /// - Parameter startTime: the end time of the task
    /// - Parameter time: the TimeSelection to sort the task
    mutating func sort(from startDate: Date?, to endDate: Date?, at time: TimeSelection) async throws {
        switch time {
        case .morning, .afternoon, .evening:
            guard let startDate, let endDate else { throw EventServiceError.unknown }
            self.startDate = startDate
            self.endDate = endDate
            self.sortStatus = .sorted(time)
            self.eventID = try await EventService.shared.scheduleEvent(for: self)
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
