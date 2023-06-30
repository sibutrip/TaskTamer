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
