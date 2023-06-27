//
//  SortStatus.swift
//  ADHDBrain
//
//  Created by Cory Tripathy on 5/16/23.
//

import Foundation

enum SortStatus: Equatable, Codable {
    case sorted(TimeSelection)
    case skipped(TimeSelection)
    case unsorted
    
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
        }
    }
}
