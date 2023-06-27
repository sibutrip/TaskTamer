//
//  AssignTimeView.swift
//  ADHDBrain
//
//  Created by Cory Tripathy on 4/30/23.
//

import SwiftUI

struct AllTasksView: View {
    @ObservedObject var vm: ViewModel
    
    var sortedTaskTimes: [Dictionary<String, [TaskItem]>.Element] {
        var taskTimes: [String:[TaskItem]] = [:]
        for task in vm.tasks {
            if taskTimes[task.sortStatus.sortName] != nil {
                taskTimes[task.sortStatus.sortName]!.append(task)
                taskTimes[task.sortStatus.sortName] = taskTimes[task.sortStatus.sortName]?.sorted { first, second in
                    if first.sortStatus == .unsorted {
                        return first.name < second.name
                    } else {
                        if let firstDate = first.scheduledDate, let secondDate = second.scheduledDate {
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
        }
    }
    
    var body: some View {
        NavigationStack {
            Group {
                if vm.tasks.isEmpty {
                    Text("You have no tasks!")
                } else {
                    List(0..<sortedTaskTimes.count, id: \.self) { index in
                        Section(sortedTaskTimes[index].key) {
                            ForEach(sortedTaskTimes[index].value) { task in
                                AllTasksRowView(task, vm)
                            }
                        }
                        .transition(.slide)
                    }
                }
            }
            .navigationTitle("All Tasks")
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
