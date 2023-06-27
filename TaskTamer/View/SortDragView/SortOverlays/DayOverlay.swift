//
//  DayOverlay.swift
//  ADHDBrain
//
//  Created by Cory Tripathy on 4/30/23.
//

import SwiftUI

struct DayOverlay: View {
    let days = Time.days
    let geo: GeometryProxy
    let skips = Time.skips
    
    @State private var dragPreference = DragPreference()
    @Binding var dragAction: DragTask
    
    var isDragging: Bool {
        dragAction.isDragging
    }
    
    var timeSelection: TimeSelection {
        return dragAction.timeSelection
    }
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                ForEach(days) { skip in
                   SortTab($dragAction, geo, skip)
                }
            }
            VStack(spacing: 0) {
                ForEach(skips) { skip in
                   SkipTab($dragAction, geo, skip)
                }
            }
            .offset(x: isDragging ? 0 : geo.size.width * -0.1)

        }
        .frame(width: geo.size.width, height: geo.size.height)
        .animation(.easeOut, value: isDragging)
    }
}
