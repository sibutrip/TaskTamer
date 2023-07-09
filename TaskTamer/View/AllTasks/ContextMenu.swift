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
                            ForEach(Array(stride(from: 15, to: 241, by: 15)), id:\.self) { num in
                                if num != task.duration(vm) {
                                    let hours = num / 60
                                    let mins = num % 60
                                    let timeMins = hours * 60 + mins
                                    let duration = Duration.seconds(timeMins * 60)
                                    let format = duration.formatted(
                                        .units(allowed: [.hours, .minutes, .seconds, .milliseconds], width: .wide))
                                    Button(format) {
                                        rescheduleInSameTimeBlock(task: task, duration: timeMins)
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
    func rescheduleInSameTimeBlock(task: TaskItem, duration: Int) {
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
            await vm.rescheduleTask(task, timeSelection, duration: duration)
        }
    }
    func rescheduleInDifferentTimeBlock(task: TaskItem, at timeSelection: TimeSelection) {
        Task {
            let duration = task.duration(vm)
            switch timeSelection {
            case .morning, .afternoon, .evening:
                await vm.rescheduleTask(task, timeSelection, duration: duration)
            case .skip1, .skip3,.skip7:
                await vm.rescheduleTask(task, timeSelection, duration: duration)
            default:
                return
            }
        }
    }
}
