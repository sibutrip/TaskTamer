//
//  DragPreference.swift
//  ADHDBrain
//
//  Created by Cory Tripathy on 4/30/23.
//

import Foundation
import SwiftUI

struct DragPreference: PreferenceKey {
    static var defaultValue: DragTask?

    static func reduce(value: inout DragTask?, nextValue: () -> DragTask?) {
        value = nextValue()
    }
}

struct DragTask: Equatable {
    let isDragging: Bool
    let timeSelection: TimeSelection
    let keyboardSelection: SortDragView.FocusedField?
}
