//
//  Time.swift
//  ADHDBrain
//
//  Created by Cory Tripathy on 5/2/23.
//

import Foundation
import SwiftUI

struct Time: Identifiable, Equatable {
    let id = UUID()
    let name: String
    let image: String
    let timeSelection: TimeSelection
    let color: Color
    
    static let days: [Time] = [
        .init(name: "Morning", image: "sunrise", timeSelection: .morning, color: .orange),
        .init(name: "Afternoon", image: "sunset", timeSelection: .afternoon, color: .cyan),
        .init(name: "Evening", image: "moon", timeSelection: .evening, color: .indigo)
    ]
    static let skips: [Time] = [
        .init(name: "Skip 1 Day", image: "backward.1", timeSelection: .skip1, color: .red),
        .init(name: "Skip 3 Days", image: "backward.3", timeSelection: .skip3, color: .red),
        .init(name: "Skip 7 Days", image: "backward.7", timeSelection: .skip7, color: .red)
    ]
}
