//
//  SortDragView.swift
//  ADHDBrain
//
//  Created by Cory Tripathy on 4/29/23.
//

import SwiftUI


struct SortDragView: View {
    
    @StateObject var dragManager = DragManager()
    
    enum FocusedField {
        case showKeyboard, dismissKeyboard
    }
    @State private var newTask = ""
    @ObservedObject var vm: ViewModel
    @FocusState private var focusedField: FocusedField?
//    {didSet{print(focusedField.debugDescription)}}
    @State var dropAction: TimeSelection = .noneSelected
    @State private var dragAction: DragTask = .init(isDragging: false, timeSelection: .noneSelected, keyboardSelection: .dismissKeyboard)
    @State private var sortDidFail: Bool = false
    
    var body: some View {
        NavigationStack {
            GeometryReader { geo in
                //            ScrollView {
                ZStack {
                    VStack {
                        if vm.unsortedTasks.count > 0 {
                            ForEach(vm.tasks) { task in
                                if task.sortStatus == .unsorted {
                                    TaskRow(task, geo)
                                        .onPreferenceChange(DropPreference.self) {
                                            dropTask in
                                            Task {
                                                do {
                                                    try await vm.sortTask(dropTask!.task, dropTask!.timeSelection)
                                                } catch {
                                                    print("sort is full")
                                                    DragManager.sortDidFail = true
                                                    sortDidFail = true
                                                }
                                            }
                                        }
                                        .onPreferenceChange(DismissKeyboardPreference.self) { dismiss in
                                            self.focusedField = nil
                                        }
                                        .onPreferenceChange(DragPreference.self) { dragAction in
                                            if let dragAction = dragAction {
                                                self.focusedField = nil
                                                self.dragAction = dragAction
                                            }
                                        }
                                        .onPreferenceChange(DismissKeyboardPreference.self) { keyboardFocus in
                                            focusedField = keyboardFocus
                                        }
                                }
                            }
                        } else {
                            Text("you have no unsorted tasks!")
                        }
                        HStack {
                            TextField("new task", text: $newTask)
                                .textFieldStyle(.roundedBorder)
                                .focused($focusedField, equals: .showKeyboard)
                                .onSubmit {
                                    addTask()
                                }
                            Button {
                                addTask()
                            } label: {
                                Image(systemName: "plus.circle")
                                    .foregroundColor(.green)
                            }
                        }
                        .padding()
                    }
                    .animation(.default, value: vm.tasks)
                    .onAppear {
                        focusedField = .none
                    }
                    DayOverlay(geo: geo, dragAction: $dragAction)
                    
                }
                .alert("Schedule is full", isPresented: $sortDidFail) {
                    Button("ok") {
                        sortDidFail = false
                        DragManager.sortDidFail = false
                    }
                }
                .transition(.slide)
                .animation(.default, value: vm.tasks)
                .coordinateSpace(name: "SortView")
                .environmentObject(dragManager)
                
            }
            .navigationTitle("Sort Tasks")
        }
    }
    
    func addTask() {
        if newTask.isEmpty {
            focusedField = .dismissKeyboard
            print("dismessied")
            return
        }
        vm.tasks.append(TaskItem(name: newTask))
        newTask.removeAll()
        focusedField = .showKeyboard
    }
}

struct SortDragView_Previews: PreviewProvider {
    static var previews: some View {
        SortDragView(vm: ViewModel())
    }
}
