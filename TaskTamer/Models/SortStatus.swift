//
//  SortStatus.swift
//  ADHDBrain
//
//  Created by Cory Tripathy on 5/16/23.
//

import Foundation

enum SortStatus: Equatable, Codable {
    
    enum Case{
        case sorted, skipped, previous, unsorted
    }
    
    case sorted(TimeSelection)
    case skipped(TimeSelection)
    case previous
    case unsorted
    
    var timeSelection: TimeSelection? {
        switch self {
        case .sorted(let timeSelection):
            return timeSelection
        case .skipped(let timeSelection):
            return timeSelection
        case .previous, .unsorted:
            return nil
        }
    }
    
    var `case`: Case {
        switch self {
        case .sorted(_):
            return .sorted
        case .skipped(_):
            return .skipped
        case .previous:
            return .previous
        case .unsorted:
            return .unsorted
        }
    }
    
    var sortName: String {
        switch self {
        case .sorted(let timeSelection):
            switch timeSelection {
            case .morning:
                return "Morning"
            case .afternoon:
                return "Afternoon"
            case .evening:
                return "Evening"
            case .other:
                return "Other"
            default:
                return ""
            }
        case .skipped(let skipSelection):
            switch skipSelection {
            case .skip1, .skip3, .skip7:
                return "Skipped"
            default:
                return ""
            }
        case .unsorted:
            return "Unsorted"
        case .previous:
            return "Previous"
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
        }
    }
}
