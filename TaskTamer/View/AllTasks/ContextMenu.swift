//
//  ContextMenu.swift
//  TaskTamer
//
//  Created by Cory Tripathy on 7/9/23.
//

import Foundation
import SwiftUI

struct AllTasksContextMenu: ViewModifier {
    @ObservedObject var vm: ViewModel
    let task: TaskItem
    func body(content: Content) -> some View {
        content
            .contextMenu {
                if !((task.sortStatus == .sorted(.other)) ^ (task.sortStatus.case ==  .skipped) ^ (task.sortStatus == .unsorted)) {
                    Menu {
                        ForEach(Array(stride(from: 15, to: 241, by: 15)), id:\.self) { minutes in
                            let timeInterval = TimeInterval(minutes * 60)
                            if timeInterval != vm.duration(of: task) {
                                let formattedTime = Duration.seconds(timeInterval).formatted(.units(allowed: [.hours, .minutes, .seconds], width: .abbreviated, zeroValueUnits: .hide, fractionalPart: .hide))
                                Button(formattedTime) {
                                    rescheduleInSameTimeBlock(task: task, duration: timeInterval)
                                }
                            }
                        }
                    } label: {
                        Label("Edit Duration", systemImage: "timer")
                    }
                    
                }
                Menu {
                    ForEach(Time.days) { day in
                        if day.name != task.sortStatus.sortName {
                            Button {
                                rescheduleInDifferentTimeBlock(task: task, at: day.timeSelection)
                            } label: {
                                Label(day.name, systemImage: day.image)
                            }
                        }
                    }
                } label: {
                    Label("Reassign Time Block", systemImage: "calendar")
                }
                Menu {
                    ForEach(Time.skips) { skip in
                        if skip.timeSelection != task.sortStatus.timeSelection {
                            Button(role: .destructive) {
                                rescheduleInDifferentTimeBlock(task: task, at: skip.timeSelection)
                            } label: {
                                Label(skip.name, image: skip.image)
                            }
                        }
                    }
                } label: {
                    Label("Skip", systemImage: "gobackward")
                }
            }
    }
    init(task: TaskItem, vm: ViewModel) {
        self.task = task
        self.vm = vm
    }
    
    func rescheduleInSameTimeBlock(task: TaskItem, duration: TimeInterval) {
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
            await vm.reschedule(task, within: timeSelection, with: duration)
        }
    }
    
    func rescheduleInDifferentTimeBlock(task: TaskItem, at timeSelection: TimeSelection) {
        Task {
            let duration = vm.duration(of: task)
            await vm.reschedule(task, within: timeSelection, with: duration)
        }
    }
}
