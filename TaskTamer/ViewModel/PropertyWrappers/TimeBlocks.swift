//
//  TimeBlocks.swift
//  TaskTamer
//
//  Created by Cory Tripathy on 7/7/23.
//

import Foundation
import SwiftUI

//class TimeBlocks {
//    static let shared = TimeBlocks()
//    @TimeBlock("morningStart", hour: 8, minute: 0) var morningStartTime
//    @TimeBlock("morningEnd", hour: 12, minute: 0) var morningEndTime
//    @TimeBlock("afternoonStart", hour: 13, minute: 0) var afternoonStartTime
//    @TimeBlock("afternoonEnd", hour: 17, minute: 0) var afternoonEndtime
//    @TimeBlock("eveningStart", hour: 17, minute: 0) var eveningStartTime
//    @TimeBlock("eveningEnd", hour: 21, minute: 0) var eveningEndTime
//
//    public func reset() {
//        morningStartTime = DateComponents.hourAndMinute(from: 8, and: 0).date!
//        morningEndTime = DateComponents.hourAndMinute(from: 12, and: 0).date!
//        afternoonStartTime = DateComponents.hourAndMinute(from: 13, and: 0).date!
//        afternoonEndtime = DateComponents.hourAndMinute(from: 17, and: 0).date!
//        eveningStartTime = DateComponents.hourAndMinute(from: 17, and: 0).date!
//        eveningEndTime = DateComponents.hourAndMinute(from: 21, and: 0).date!
//    }
//}

@propertyWrapper
struct TimeBlock: DynamicProperty {
    let key: String
    var projectedValue: Int
    var wrappedValue: Date {
        get {
            let mins = projectedValue % 60
            let hours = projectedValue / 60
            let date = Calendar.current.date(from: DateComponents.hourAndMinute(from: hours, and: mins))!
            return date
        }
        set {
            let components = Calendar.autoupdatingCurrent.dateComponents([.hour,.minute], from: newValue)
            projectedValue = components.hour! * 60 + components.minute!
            UserDefaults.standard.set(projectedValue, forKey: key)
        }
    }
    init(_ key: String, hour: Int, minute: Int) {
        self.key = key
        let savedValue = UserDefaults.standard.value(forKey: key) as? Int
        if let savedValue = savedValue {
            self.projectedValue = savedValue
        } else {
            self.projectedValue = hour * 60 + minute
        }
    }
}
