//
//  Task.swift
//  ADHDBrain
//
//  Created by Cory Tripathy on 4/29/23.
//

import Foundation

enum ScheduleError: Error {
    case scheduleFull
}

struct TaskItem: Identifiable, Equatable, Codable {
    var id: String
    let name: String
    var sortStatus: SortStatus = .unsorted
    var startDate: Date?
    var endDate: Date?
    var scheduleDescription: String {
        switch sortStatus {
        case .sorted(_):
            if DateComponents(calendar: Calendar.autoupdatingCurrent, timeZone: .autoupdatingCurrent, day: Calendar.autoupdatingCurrent.component(.day, from: Date())) != DateComponents(calendar: Calendar.autoupdatingCurrent, timeZone: .autoupdatingCurrent, day: Calendar.autoupdatingCurrent.component(.day, from: self.startDate ?? Date.distantPast)) {
                return "\(startDate?.formatted() ?? "") to \(endDate?.formatted(date: .omitted, time: .shortened) ?? "")"
            } else {
                return "Today, \(startDate?.formatted(date: .omitted, time: .shortened) ?? "") to \(endDate?.formatted(date: .omitted, time: .shortened) ?? "")"
            }
        case .skipped(_):
            return "skipped until \(startDate?.formatted() ?? "")"
        case .unsorted:
            return "unsorted"
        }
    }
    
    init(name: String) {
        id = UUID().uuidString
        self.name = name
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.name = try container.decode(String.self, forKey: .name)
        self.startDate = try container.decodeIfPresent(Date.self, forKey: .startDate)
        self.endDate = try container.decodeIfPresent(Date.self, forKey: .endDate)
        if let endDate = endDate {
            if Date() > endDate {
                self.sortStatus = .unsorted
            } else {
                self.sortStatus = try container.decode(SortStatus.self, forKey: .sortStatus)
            }
        }
    }
    
    mutating func sort(duration: TimeInterval, at time: TimeSelection, within tasks: [TaskItem]) async throws {
        switch time {
        case .morning, .afternoon, .evening:
            let eventService = EventService.shared
            let scheduledDate = eventService.selectDate(duration: duration, from: time, within: tasks)
            guard let scheduledDate = scheduledDate else {
                throw ScheduleError.scheduleFull
            }
            (self.startDate, self.endDate) = scheduledDate
            self.sortStatus = .sorted(time)
            try await eventService.scheduleEvent(for: &self)
        case .skip1:
            self.sortStatus = .skipped(time)
            self.startDate = Calendar.current.date(byAdding: .day, value: 1, to: DateComponents.midnight.date!)!
        case .skip3:
            self.sortStatus = .skipped(time)
            self.startDate = Calendar.current.date(byAdding: .day, value: 3, to: DateComponents.midnight.date!)!
        case .skip7:
            self.sortStatus = .skipped(time)
            self.startDate = Calendar.current.date(byAdding: .day, value: 7, to: DateComponents.midnight.date!)!
        case .noneSelected:
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
