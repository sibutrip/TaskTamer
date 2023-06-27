//
//  TaskRow.swift
//  ADHDBrain
//
//  Created by Cory Tripathy on 4/29/23.
//

import SwiftUI

struct TaskRow: View {
    let task: TaskItem
    let geo: GeometryProxy
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .foregroundColor(.taskRow).opacity(1.0)
            RoundedRectangle(cornerRadius: 10)
                .stroke()
            Text(task.name)
        }
        .frame(maxHeight: geo.size.height / 10)
        .modifier(SwipeGesture(geo, with: task))
    }
    init(_ task: TaskItem, _ geo: GeometryProxy) {
        self.task = task
        self.geo = geo
    }
}

struct TaskRow_Previews: PreviewProvider {
    static var previews: some View {
        GeometryReader { geo in
            TaskRow(TaskItem(name: "woo"), geo)
        }
    }
}
