//
//  SortTab.swift
//  ADHDBrain
//
//  Created by Cory Tripathy on 5/2/23.
//

import SwiftUI

struct SortTab: View {
    let geo: GeometryProxy
    let sort: Time
    
    @Binding var dragAction: DragTask
    var isDragging: Bool {
        dragAction.isDragging
    }
    
    var timeSelection: TimeSelection {
        return dragAction.timeSelection
    }
    
    
    var body: some View {
        Circle()
            .foregroundColor(Color.sort)
            .opacity(isDragging ? 0.75 : 0.0)
            .frame(width: geo.size.width, alignment: .trailing)
            .offset(x: geo.size.height / 4)
            .overlay {
                HStack {
                    Spacer()
                    Image(systemName: sort.image)
                        .resizable()
                        .scaledToFit()
                        .frame(width: geo.size.width / 10, alignment: .trailing)
                }
                .padding(.trailing, 10)
            }
            .opacity(isDragging ? 1.0 : 0.0)
            .offset(x: timeSelection == sort.timeSelection ? geo.size.width / -20: 0)
            .animation(.easeOut, value: timeSelection)
    }
    
    init(_ dragAction: Binding<DragTask>, _ geo: GeometryProxy, _ sort: Time) {
        self.geo = geo
        _dragAction = dragAction
        self.sort = sort
    }
}
