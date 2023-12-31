//
//  AllTasksRowView.swift
//  ADHDBrain
//
//  Created by Cory Tripathy on 5/11/23.
//

import Foundation
import SwiftUI

struct AllTasksRowView: View {
    let task: TaskItem
    @ObservedObject var vm: ViewModel
    @State private var deleteDidFail = false
    
    var scheduleColor: Color {
        switch task.sortStatus {
            
        case .sorted(let status):
            switch status {
                
            case .morning, .afternoon, .evening, .other:
                return Color.green
            default:
                return Color.black
            }
        case .skipped(let status):
            switch status {
                
            case .skip1,.skip3,.skip7:
                return Color.red
            default:
                return Color.black
            }
        case .unsorted:
            return Color.primary
        case .previous:
            return Color.red
        }
    }
    
    var body: some View {
        
        VStack(alignment: .leading) {
            HStack {
                Text(task.name)
                Spacer()
            }
            if !((task.sortStatus != .previous) ^ (task.sortStatus != .unsorted)) {
                Text(task.scheduleDescription)
                    .font(.caption)
                    .foregroundColor(scheduleColor)
            }
        }
        .contentShape(Rectangle())
        .modifier(AllTasksContextMenu(task: task, vm: vm))
        .modifier(Unsort($vm.tasks, task, vm))
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            //TODO: make this a viewmodifier
            Button {
                Task {
                    do {
                        try await vm.delete(task)
                    } catch {
                        deleteDidFail = true
                    }
                }
            } label: {
                Label("Delete", systemImage: "trash")
            }
            .tint(.red)
        }
        .alert("could not delete sorry", isPresented: $deleteDidFail) {
            Button("ok") { deleteDidFail = false }
        }
        .animation(.default, value: vm.tasks)
    }
    init(_ task: TaskItem, _ vm: ViewModel) {
        self.task = task
        self.vm = vm
    }
}
