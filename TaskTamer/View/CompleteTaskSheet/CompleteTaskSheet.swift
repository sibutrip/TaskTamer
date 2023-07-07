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
    @State var selectedTasks: [TaskItem] = []
    var body: some View {
        NavigationStack {
            Group {
                if vm.previousTasks.isEmpty {
                    VStack {
                        Text("No previous tasks to mark as complete!")
                        Text("Sorted tasks from the past will appear here.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                } else {
                    Form {
                        Section("Previous Tasks") {
                            List(vm.previousTasks) { task in
                                Button {
                                    withAnimation(.default.speed(2.5)) {
                                        if selectedTasks.contains(where: { $0 == task }) {
                                            selectedTasks.removeAll { $0 == task }
                                        } else {
                                            selectedTasks.append(task)
                                        }
                                    }
                                } label: {
                                    HStack {
                                        Image(systemName: selectedTasks.contains { $0 == task } ? "checkmark.square" : "square")
                                        Text(task.name)
                                        Spacer()
                                    }
                                    .contentShape(Rectangle())
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        Button("Mark Selected as Complete") {
                            selectedTasks.forEach { task in
                                do {
                                    try vm.deleteTask(task)
                                } catch { print(error.localizedDescription) }
                            }
                            vm.tasks.removeAll { task in
                                selectedTasks.contains { $0 == task }
                            }
                            dismiss()
                        }
                    }
                }
            }
            .navigationTitle("Complete Tasks")
        }
    }
    
    init(_ vm: ViewModel) {
        self.vm = vm
    }
}
