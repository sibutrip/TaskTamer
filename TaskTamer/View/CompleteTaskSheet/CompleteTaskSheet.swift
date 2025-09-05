//
//  CompleteTaskSheet.swift
//  TaskTamer
//
//  Created by Cory Tripathy on 7/6/23.
//

import Foundation
import SwiftUI

struct PreviousTaskSheet: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var vm: ViewModel
    var body: some View {
        NavigationStack {
            Form {
                Section("Incomplete Tasks") {
                    if vm.incompleteTasks.isEmpty {
                        VStack {
                            Text("No previous tasks to mark as complete!")
                            Text("Sorted tasks from the past will appear here.")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    } else {
                        List(vm.incompleteTasks) { task in
                            HStack {
                                Text(task.name)
                                Spacer()
                                Button("Mark complete", systemImage: "checkmark.circle") {
                                    withAnimation(.default.speed(2.5)) {
                                        vm.complete(task)
                                    }
                                }
                                .foregroundStyle(Color.green)
                                .labelStyle(.iconOnly)
                                .font(.title2)
                                .buttonStyle(.plain)
                                Button("Mark incomplete", systemImage: "x.circle") {
                                    Task { await vm.unschedule(task) }
                                }
                                .foregroundStyle(Color.red)
                                .labelStyle(.iconOnly)
                                .font(.title2)
                                .buttonStyle(.plain)
                            }
                            .contentShape(Rectangle())
                        }
                    }
                }
                if !vm.completedTasks.isEmpty {
                    Section("Completed Tasks") {
                        List {
                            ForEach(vm.completedTasks) { task in
                                Text(task.name)
                                    .modifier(AllTasksContextMenu(task: task, vm: vm))
                                    .modifier(Unsort($vm.tasks, task, vm))
                            }
                            .onDelete { indexSet in
                                let tasksToDelete = indexSet.map { vm.completedTasks[$0] }
                                vm.tasks.removeAll(where: tasksToDelete.contains)
                            }
                        }
                    }
                }
            }
            .animation(.default, value: vm.tasks)
            .navigationTitle("Previous Tasks")
        }
    }

    init(_ vm: ViewModel) {
        self.vm = vm
    }
}

#Preview {
    let vm = ViewModel()
    var completedTask = TaskItem(name: "completed task")
    completedTask.sortStatus = .complete
    var previousTask = TaskItem(name: "previous task")
    previousTask.sortStatus = .previous
    //    vm.tasks = [previousTask]
    //    vm.tasks = [completedTask]
    vm.tasks = [completedTask, previousTask]
    return PreviousTaskSheet(vm)
}
