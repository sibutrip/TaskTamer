//
//  SortStatus.swift
//  ADHDBrain
//
//  Created by Cory Tripathy on 5/16/23.
//

import Foundation

enum SortStatus: Equatable, Codable {
    
    enum Case {
        case sorted, skipped, previous, unsorted, complete
    }
    
    case sorted(TimeSelection)
    case skipped(TimeSelection)
    case previous
    case unsorted
    case complete

    var timeSelection: TimeSelection? {
        switch self {
        case .sorted(let timeSelection):
            timeSelection
        case .skipped(let timeSelection):
            timeSelection
        case .previous, .unsorted, .complete:
            nil
        }
    }
    
    var `case`: Case {
        switch self {
        case .sorted(_):
            .sorted
        case .skipped(_):
            .skipped
        case .previous:
            .previous
        case .unsorted:
            .unsorted
        case .complete:
            .complete
        }
    }
    
    var sortName: String {
        switch self {
        case .sorted(let timeSelection):
            switch timeSelection {
            case .morning:
                "Morning"
            case .afternoon:
                "Afternoon"
            case .evening:
                "Evening"
            case .other:
                "Other"
            default:
                ""
            }
        case .skipped(let skipSelection):
            switch skipSelection {
            case .skip1, .skip3, .skip7:
                "Skipped"
            default:
                ""
            }
        case .unsorted:
            "Unsorted"
        case .previous:
            "Previous"
        case .complete:
            "Complete"
        }
    }
    
    var isScheduled: Bool {
        switch self {
        case .sorted(_):
            true
        case .skipped(_):
            false
        case .previous:
            true
        case .unsorted:
            false
        case .complete:
            true
        }
    }

    var canEditDuration: Bool {
        self != .sorted(.other) &&
        self.case != .skipped &&
        self != .previous &&
        self != .unsorted &&
        self != .complete
    }

    var showScheduleDescription: Bool {
        self != .previous &&
        self != .unsorted &&
        self != .complete
    }
}
