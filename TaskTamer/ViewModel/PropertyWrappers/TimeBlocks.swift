//
//  TimeBlocks.swift
//  TaskTamer
//
//  Created by Cory Tripathy on 7/7/23.
//

import Foundation
import SwiftUI

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
