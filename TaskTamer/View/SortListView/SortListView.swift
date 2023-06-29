//
//  SortListView.swift
//  ADHDBrain
//
//  Created by Cory Tripathy on 4/29/23.
//

import SwiftUI

struct SortListView: View {
    
    @Environment(\.editMode) var editMode
    
    @ScaledMetric(relativeTo: .body) var scaledPadding: CGFloat = 10
    
    @StateObject var dragManager = DragManager()
    
    enum FocusedField {
        case showKeyboard, dismissKeyboard
    }
    @State private var newTask = ""
    @ObservedObject var vm: ViewModel
    @FocusState private var isFocused
    @State var dropAction: TimeSelection = .noneSelected
    @State private var dragAction: DragTask = .init(isDragging: false, timeSelection: .noneSelected, keyboardSelection: .dismissKeyboard)
    @State private var sortDidFail: Bool = false
    @State private var taskExpanded: TaskItem?
    @State private var disclosure: Bool = false
    
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color("ListBackground")
                    .ignoresSafeArea()
                ScrollView {
                    GeometryReader { geo in
                        
                        VStack(spacing: 0) {
                            ForEach(0..<vm.unsortedTasks.count, id: \.self) { index in
                                SortListDisclosure(vm, index, $taskExpanded, geo)
                                    .background { Color("ListForeground") }
                            }
                            .onDelete { indexSet in
                                guard let index = indexSet.first else { return }
                                let task = vm.unsortedTasks[index]
                                vm.tasks.removeAll { $0.id == task.id  }
                            }
                            
                            HStack {
                                TextField(text: $newTask) {
                                    Text(newTask)
                                        .background { Color("ListForeground") }
                                }
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
                            .padding(.top,scaledPadding)
                            .padding(.horizontal)
                        }
                        .padding(.bottom, scaledPadding)
                        .background { Color.primary.colorInvert() }
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                }
                
                .padding(.horizontal)
                Spacer()
            }
            .toolbar {
                EditButton()
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

struct SortListView_Previews: PreviewProvider {
    static var previews: some View {
        SortListView(vm: ViewModel())
    }
}
