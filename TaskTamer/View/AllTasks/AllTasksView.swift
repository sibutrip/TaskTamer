//
//  AssignTimeView.swift
//  ADHDBrain
//
//  Created by Cory Tripathy on 4/30/23.
//

import SwiftUI

struct AllTasksView: View {
    //    @Environment(\.defaultMinListRowHeight) var minRow
    @ScaledMetric(relativeTo: .body) var scaledPadding: CGFloat = 10
    @ObservedObject var vm: ViewModel
    @Environment(\.scenePhase) private var scenePhase
    @State var taskExpanded: TaskItem? = nil
    @State var taskDeleting: TaskItem? = nil
    
    var sortedTaskTimes: [Dictionary<String, [TaskItem]>.Element] {
        var taskTimes: [String:[TaskItem]] = [:]
        for task in vm.tasks {
            if taskTimes[task.sortStatus.sortName] != nil {
                taskTimes[task.sortStatus.sortName]!.append(task)
                taskTimes[task.sortStatus.sortName] = taskTimes[task.sortStatus.sortName]?.sorted { first, second in
                    if first.sortStatus == .unsorted {
                        return first.name < second.name
                    } else {
                        if let firstDate = first.startDate, let secondDate = second.startDate {
                            return firstDate < secondDate
                        }
                    }
                    return true
                }
            } else {
                taskTimes[task.sortStatus.sortName] = [task]
            }
        }
        return taskTimes.sorted { first, second in
            if first.key == "Morning" {
                return true
            } else if second.key == "Morning" {
                return false
            } else if first.key == "Afternoon" {
                return true
            } else if second.key == "Afternoon" {
                return false
            } else if first.key == "Evening" {
                return true
            } else if second.key == "Evening" {
                return false
            } else if first.key == "Other" {
                return true
            } else if second.key == "Other" {
                return false
            } else if first.key == "Skipped" {
                return true
            } else if second.key == "Skipped" {
                return false
            }  else if first.key == "Unsorted" {
                return true
            } else if second.key == "Unsorted" {
                return false
            }
            return false
        }
    }
    
    func scheduleColor(_ task: TaskItem) -> Color {
        switch task.sortStatus {
        case .skipped(_):
            return .red
        case .sorted(_):
            return .green
        case .unsorted:
            return .primary
        case .previous:
            return .red
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color("ListBackground")
                    .ignoresSafeArea()
                GeometryReader { geo in
                    ScrollView {
                        VStack(spacing: 0) {
                            if vm.tasks.isEmpty {
                                Text("You have no tasks!")
                            } else {
                                ForEach(0..<sortedTaskTimes.count, id: \.self) { index in
                                    HStack(spacing: 0) {
                                        Text(sortedTaskTimes[index].key.uppercased())
                                            .foregroundColor(.secondary)
                                            .font(.caption)
                                        Spacer()
                                    }
                                    .padding(scaledPadding * 0.5)
                                    .padding(.top, scaledPadding * 0.5)
                                    .padding(.leading)
                                    LazyVStack(spacing: 0) {
                                        ForEach(0..<sortedTaskTimes[index].value.count, id: \.self) { sortedIndex in
                                            let task = sortedTaskTimes[index].value[sortedIndex]
                                            Group {
                                                if sortedTaskTimes[index].key == "Previous" {
                                                    SortList(vm, task, geo, $taskDeleting)
                                                } else {
                                                    SortListDisclosure(vm, task, $taskExpanded, geo, $taskDeleting)
                                                }
                                            }
                                            .background { Color("ListForeground") }
                                            if (sortedIndex + 1) != (sortedTaskTimes[index].value.count) {
                                                Divider()
                                                    .padding(.top, scaledPadding)
                                            }
                                        }
                                    }
                                    .padding(.bottom, scaledPadding)
                                    .background { Color("ListForeground") }
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                }
                            }
                        }
                    }
                    .scrollDismissesKeyboard(.immediately)
                }
                .padding(.horizontal)
            }
            .navigationTitle("All Tasks")
            .onChange(of: scenePhase) { newValue in
                if newValue == .active { vm.refreshTasks() }
            }
            .onAppear { vm.refreshTasks() }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    CompleteTaskToolbar(vm)
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    SettingsToolbar(vm)
                }
            }
        }
    }
}


struct AllTasksView_Previews: PreviewProvider {
    static var previews: some View {
        AllTasksView(vm: ViewModel())
        AllTasksView(vm: ViewModel())
            .previewDevice(PreviewDevice(rawValue: "iPad Pro (11-inch)"))
    }
}
