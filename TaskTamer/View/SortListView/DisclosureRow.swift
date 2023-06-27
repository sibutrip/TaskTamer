//
//  DisclosureRow.swift
//  ADHDBrain
//
//  Created by Cory Tripathy on 5/31/23.
//

import Foundation
import SwiftUI

struct DisclosureRow: View {
    let task: TaskItem
    @ObservedObject var vm: ViewModel
    @Binding var taskExpanded: TaskItem?

    let times: [Time]
    let rowTitle: String
    var body: some View {
        VStack {
            HStack {
                ForEach(times) { skip in
                    Button {
                        Task {
                            do {
                                try await vm.sortTask(task, skip.timeSelection)
                                taskExpanded = nil
                            } catch {
                                vm.sortDidFail = true
                            }
                        }
                    } label: {
                        if times == Time.days {
                            Label(skip.name, systemImage: skip.image)
                                .foregroundColor(skip.color)
                                .labelStyle(.iconOnly)
                                .padding(5)
                        } else {
                            Label(skip.name, image: skip.image)
                                .foregroundColor(skip.color)
                                .labelStyle(.iconOnly)
                                .padding(5)
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
            Text(rowTitle)
                .font(.caption)
        }
    }
    
    init(for times: [Time], _ vm: ViewModel, _ task: TaskItem, _ taskExpanded: Binding<TaskItem?>) {
        self.times = times
        self.task = task
        self.vm = vm
        _taskExpanded = taskExpanded
        if times == Time.days {
            rowTitle = "Schedule"
        } else {
            rowTitle = "Skip"
        }
    }
}
