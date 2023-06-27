//
//  SortSwipeView.swift
//  TaskTamer
//
//  Created by Cory Tripathy on 6/27/23.
//

import SwiftUI

struct SortSwipeView: View {
    @ObservedObject var vm: ViewModel
    enum FocusedField {
        case showKeyboard, dismissKeyboard
    }
    @State private var newTask = ""
    @FocusState private var isFocused
    var body: some View {
        NavigationStack {
            List {
                ForEach(0..<vm.unsortedTasks.count, id: \.self) { index in
                    let task = vm.unsortedTasks[index]
                    Text(task.name)
                        .swipeActions(edge: .leading, allowsFullSwipe: false) {
                            Button {
                                Task { try await vm.sortTask(task, .skip1) }
                            } label: {
                                Label("Delete", image: "backward.1")
                            }
                            .tint(.red)
                        }
                        .swipeActions(edge: .leading, allowsFullSwipe: false) {
                            Button {
                                Task { try await vm.sortTask(task, .skip3) }
                            } label: {
                                Label("Delete", image: "backward.3")
                            }
                            .tint(.red)
                        }
                        .swipeActions(edge: .leading, allowsFullSwipe: false) {
                            Button {
                                Task { try await vm.sortTask(task, .skip7) }
                            } label: {
                                Label("Delete", image: "backward.7")
                            }
                            .tint(.red)
                        }
                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                            Button {
                                Task { try await vm.sortTask(task, .evening) }
                            } label: {
                                Label("Delete", systemImage: "moon")
                            }
                            .tint(.indigo)
                        }
                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                            Button {
                                Task { try await vm.sortTask(task, .afternoon) }
                            } label: {
                                Label("Delete", systemImage: "sunset")
                            }
                            .tint(.cyan)
                        }
                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                            Button {
                                Task { try await vm.sortTask(task, .morning) }
                            } label: {
                                Label("Delete", systemImage: "sunrise")
                            }
                            .tint(.yellow)
                        }
                }
//                .onDelete { indexSet in
//                    guard let index = indexSet.first else { return }
//                    let task = vm.unsortedTasks[index]
//                    vm.tasks.removeAll { $0.id == task.id  }
//                }
                HStack {
                    TextField("New task...", text: $newTask)
//                        .focused($isFocused)
                        .onSubmit {
                            addTask()
                        }
                    Button {
                        addTask()
                    } label: {
                        Image(systemName: "plus.circle")
                            .foregroundColor(.accentColor)
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    EditButton()
                }
            }
            .navigationTitle("Sort Tasks")
            .overlay {
                if vm.tasks.isEmpty {
                    Text("You have no tasks!")
                }
            }
            .alert("Your schedule at that time full. Try scheduling this event at a different time.", isPresented: $vm.sortDidFail) {
                Button("ok") { vm.sortDidFail = false }
            }
        }
    }
    
    func addTask() {
        if newTask.isEmpty {
            isFocused = false
            return
        }
        vm.tasks.append(TaskItem(name: newTask))
        newTask.removeAll()
        isFocused = true
    }
    
}

struct SortSwipeView_Previews: PreviewProvider {
    static var previews: some View {
        SortSwipeView(vm: ViewModel())
    }
}
