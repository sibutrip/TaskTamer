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
        .contextMenu {
            Menu("Edit Duration") {
                    ForEach(Array(stride(from: 15, to: 241, by: 15)), id:\.self) { num in
                        let hours = num / 60
                        let mins = num % 60
                        let timeMins = hours * 60 + mins
                        let duration = Duration.seconds(timeMins * 60)
                        let format = duration.formatted(
                            .units(allowed: [.hours, .minutes, .seconds, .milliseconds], width: .wide))
                        Button(format) {
                            reschedule(task: task, at: timeMins)
                        }
                    }
            }
        }
        .modifier(Unsort($vm.tasks, task, vm))
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            //TODO: make this a viewmodifier
            Button {
                do {
                    try vm.deleteTask(task)
                } catch {
                    deleteDidFail = true
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

extension AllTasksRowView {
    func reschedule(task: TaskItem, at time: Int) {
        Task {
            let timeSelection: TimeSelection
            switch task.sortStatus {
            case .sorted(let sort):
                timeSelection = sort
            case .skipped(let skip):
                timeSelection = skip
            case .previous, .unsorted:
                return
            }
            await vm.rescheduleTask(task, timeSelection, duration: time)
        }
    }
}
