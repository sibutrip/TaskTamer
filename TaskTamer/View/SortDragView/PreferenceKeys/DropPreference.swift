//
//  DropPreference.swift
//  ADHDBrain
//
//  Created by Cory Tripathy on 4/30/23.
//

import Foundation
import SwiftUI

struct DropPreference: PreferenceKey {
    static var defaultValue: (DropTask)?

    static func reduce(value: inout DropTask?, nextValue: () -> DropTask?) {
        value = nextValue()
    }
}

struct DropTask: Equatable {
    let task: TaskItem
    let timeSelection: TimeSelection
}
