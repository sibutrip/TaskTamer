//
//  SkipTab.swift
//  ADHDBrain
//
//  Created by Cory Tripathy on 5/2/23.
//

import SwiftUI

struct SkipTab: View {
    let geo: GeometryProxy
    let skip: Time
    
    @Binding var dragAction: DragTask
    var isDragging: Bool {
        dragAction.isDragging
    }
    
    var timeSelection: TimeSelection {
        return dragAction.timeSelection
    }
    
    
    var body: some View {
        Circle()
            .foregroundColor(.skip)
            .opacity(isDragging ? 0.75 : 0.0)
            .frame(width: geo.size.width, alignment: .leading)
            .offset(x: -geo.size.height / 4)
            .overlay {
                HStack {
                    Image(skip.image)
                        .resizable()
                        .scaledToFit()
                        .frame(width: geo.size.width / 10, alignment: .leading)
//                        .overlay { Text(skip.name) }
                    Spacer()
                }
                .padding(.leading, 10)
            }
            .opacity(isDragging ? 1.0 : 0.0)
            .offset(x: timeSelection == skip.timeSelection ? geo.size.width / 20: 0)
            .animation(.easeOut, value: timeSelection)
        
    }
    
    init(_ dragAction: Binding<DragTask>, _ geo: GeometryProxy, _ skip: Time) {
        self.geo = geo
        _dragAction = dragAction
        self.skip = skip
    }
}
