//
//  SortListView.swift
//  ADHDBrain
//
//  Created by Cory Tripathy on 4/29/23.
//

import SwiftUI

struct SortListView: View {
    
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
    @State private var taskDeleting: TaskItem?
    @State private var disclosure: Bool = false
    
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color("ListBackground")
                    .ignoresSafeArea()
                GeometryReader { geo in
                    ScrollView {
                        LazyVStack(spacing: 0) {
                            ForEach(0..<vm.unsortedTasks.count, id: \.self) { index in
                                SortListDisclosure(vm, index, $taskExpanded, geo, $taskDeleting)
                                    .background { Color("ListForeground") }
                            }
                            HStack {
                                TextField(text: $newTask, prompt: Text("Add a Task")) {
                                    Text(newTask)
                                }
                                .onSubmit {
                                    //                                    (0...10).forEach { _ in
                                    addTask()
                                    //                                    }
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
            .navigationTitle("Sort Tasks")
            .overlay {
                if vm.unsortedTasks.isEmpty {
                    Text("You have no unsorted tasks!")
                }
            }
            .alert("Your schedule at that time full. Try scheduling this event at a different time.", isPresented: $vm.scheduleFull) {
                Button("ok") { vm.scheduleFull = false }
            }
            .alert("Enable Calendar permissions in your Settings to schedule an event.", isPresented: $vm.noPermission) {
                HStack {
                    Button("No thanks") { vm.noPermission = false }
                    Button("Take me there") {
//                        vm.noPermission = false
                        Task {
                            if let url = URL(string: UIApplication.openSettingsURLString) {
                                // Ask the system to open that URL.
                                await UIApplication.shared.open(url)
                            }
                        }
                    }
                    .keyboardShortcut(.defaultAction)
                }
            }
            .alert("An unknown error occured. Please submit a bug report ;)", isPresented: $vm.unknownError) {
                Button("Ok") { vm.unknownError = false }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    CompleteTaskToolbar(vm)
                }
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
