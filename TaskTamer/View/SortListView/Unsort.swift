//
//  Unsort.swift
//  ADHDBrain
//
//  Created by Cory Tripathy on 5/12/23.
//

import Foundation
import SwiftUI

struct Unsort: ViewModifier {
    @Binding var tasks: [TaskItem]
    let task: TaskItem
    @ObservedObject var vm: ViewModel
    
    init(_ tasks: Binding<[TaskItem]>, _ task: TaskItem, _ vm:ViewModel) {
        _tasks = tasks
        self.task = task
        self.vm = vm
    }
    
    func body(content: Content) -> some View {
        if task.sortStatus != .unsorted {
            content
                .swipeActions(edge: .leading, allowsFullSwipe: true) {
                    Button {
                        withAnimation {
                            vm.unscheduleTask(task)
                        }
                    } label: {
                        Label("Unsort", systemImage: "arrow.uturn.backward")
                    }
                    .tint(.yellow)
                }
        } else {
            content
        }
    }
}
