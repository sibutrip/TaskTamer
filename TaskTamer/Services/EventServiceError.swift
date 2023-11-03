//
//  EventServiceError.swift
//  TaskTamer
//
//  Created by Cory Tripathy on 7/6/23.
//

import Foundation

enum EventServiceError: Error {
    case noPermission, scheduleFull, unknown
}

extension EventServiceError : LocalizedError {
    
    public var errorDescription: String? {
        switch self {
        case .noPermission:
            return NSLocalizedString("Enable Calendar Permissions in Settings.", comment: "")
        case .scheduleFull:
            return NSLocalizedString("Schedule full. Schedule this event at another time.", comment: "")
        case .unknown:
            return NSLocalizedString("Unknown issue scheduling event", comment: "")
        }
    }
    public var failureReason: String? {
        switch self {
        case .noPermission:
            return NSLocalizedString("Calendar Permission Not Granted.", comment: "")
        case .scheduleFull:
            return NSLocalizedString("Failed To Save Event.", comment: "")
        case .unknown:
            return NSLocalizedString("Failed To Save Event for unknown reason.", comment: "")
        }
    }
    public var recoverySuggestion: String? {
        switch self {
        case .noPermission:
            return NSLocalizedString("Enable Calendar permissions in Settings.", comment: "")
        case .scheduleFull:
            return NSLocalizedString("Schedule this event at another time.", comment: "")
        case .unknown:
            return NSLocalizedString("Developer Error.", comment: "")
        }
    }
}
