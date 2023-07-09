//
//  Haptic.swift
//  TaskTamer
//
//  Created by Cory Tripathy on 7/9/23.
//

import Foundation
import CoreHaptics
import SwiftUI

class Haptic {
    static func medium() {
        let medium = UIImpactFeedbackGenerator(style: .medium)
        medium.impactOccurred()
    }
}
