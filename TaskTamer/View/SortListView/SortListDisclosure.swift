//
//  SortListDisclosure.swift
//  ADHDBrain
//
//  Created by Cory Tripathy on 5/31/23.
//

import Foundation
import SwiftUI

struct SortListDisclosure: View {
    @ObservedObject var vm: ViewModel
    let task: TaskItem
    
    @Environment(\.editMode) var editMode
    @Binding var taskExpanded: TaskItem?
    
    var body: some View {
        DisclosureGroup(isExpanded:
                            Binding<Bool>(
                                get: {
                                    self.taskExpanded == task && editMode?.wrappedValue != .active
                                },
                                set: { isExpanding in
                                    if isExpanding {
                                        self.taskExpanded = task
                                    } else {
                                        self.taskExpanded = nil
                                    }
                                }
                            )
        ) {
            HStack(alignment: .center) {
                DisclosureRow(for: Time.skips, vm, task, $taskExpanded)
                Spacer()
                DisclosureRow(for: Time.days, vm, task, $taskExpanded)
            }
        } label: {
            Text(task.name)
        }
    }
    
    init(_ vm: ViewModel, _ task: TaskItem, _ taskExpanded: Binding<TaskItem?>) {
        self.vm = vm
        self.task = task
        _taskExpanded = taskExpanded
    }
}

struct SortDisclosureStyle: DisclosureGroupStyle {
    func makeBody(configuration: Configuration) -> some View {
        Group {
            VStack(alignment: .leading) {
                Button {
                    configuration.isExpanded.toggle()
                } label: {
                    configuration.label
                }
                if configuration.isExpanded {
                    configuration.content
                        .listStyle(.plain)
                }
            }
        }
    }
}
