//
//  DateComponents+Extension.swift
//  TaskTamer
//
//  Created by Cory Tripathy on 6/30/23.
//

import Foundation

extension DateComponents {
    static let midnight = DateComponents(calendar: Calendar.current, timeZone: .autoupdatingCurrent, year: Calendar.current.component(.year, from: Date()), month: Calendar.current.component(.month, from: Date()), day: Calendar.current.component(.day, from: Date()), hour: 0, minute: 0, second: 0)
    
    static let currentDayComponent = DateComponents(calendar: Calendar.autoupdatingCurrent, timeZone: .autoupdatingCurrent, day: Calendar.autoupdatingCurrent.component(.day, from: Date()))
    
    static func hour(from hour: Int) -> DateComponents {
        DateComponents(calendar: Calendar.current, timeZone: .autoupdatingCurrent, year: Calendar.current.component(.year, from: Date()), month: Calendar.current.component(.month, from: Date()), day: Calendar.current.component(.day, from: Date()), hour: hour, minute: 0, second: 0)
    }
}

extension Date {
    static func hourAddingDayIfNeeded(from hour: Int) -> Date {
        DateComponents.hour(from: hour).date! > Date() ? DateComponents.hour(from: hour).date! : DateComponents.hour(from: hour).date!.addingTimeInterval(86400)
    }
    
    static var nearestQuarterHour: Date {
        let minute = Calendar.current.component(.minute, from: Date())
        var filteredMinute: Int {
            if minute > 0 && minute < 15 {
                return 15
            } else if minute >= 15 && minute < 30 {
                return 30
            } else if minute >= 30 && minute < 45 {
                return 45
            } else {
                return 60
            }
        }
        return DateComponents(calendar: Calendar.current, timeZone: .autoupdatingCurrent, year: Calendar.current.component(.year, from: Date()), month: Calendar.current.component(.month, from: Date()), day: Calendar.current.component(.day, from: Date()), hour: Calendar.current.component(.hour, from: Date()), minute: filteredMinute, second: 0).date!
    }
    var adjustedToCurrentDay: Date {
        DateComponents(calendar: Calendar.current, timeZone: .autoupdatingCurrent, year: Calendar.current.component(.year, from: Date()), month: Calendar.current.component(.month, from: Date()), day: Calendar.current.component(.day, from: Date()), hour: Calendar.current.component(.hour, from: self), minute: Calendar.current.component(.minute, from: self), second: 0).date!
    }
}
