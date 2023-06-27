//
//  DismissKeyboardPreference.swift
//  ADHDBrain
//
//  Created by Cory Tripathy on 5/13/23.
//

import Foundation
import SwiftUI

struct DismissKeyboardPreference: PreferenceKey {
    static var defaultValue: SortDragView.FocusedField?

    static func reduce(value: inout SortDragView.FocusedField?, nextValue: () -> SortDragView.FocusedField?) {
        value = nextValue()
    }
}
