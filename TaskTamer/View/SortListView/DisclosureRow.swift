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
    @Binding var timeBlockDuration: Int
    
    let times: [Time]
    let rowTitle: String
    var body: some View {
        VStack {
            HStack {
                ForEach(times) { skip in
                    Button {
                        Task {
                            await vm.sortTask(task, skip.timeSelection, duration: timeBlockDuration)
                            taskExpanded = nil
                        }
                    } label: {
                        if times == Time.days {
                            Label(skip.name, systemImage: skip.image)
                                .foregroundColor(skip.color)
                                .labelStyle(.iconOnly)
                                .padding(.horizontal, 5)
                                .padding(.vertical, 3)
                        } else {
                            Label(skip.name, image: skip.image)
                                .foregroundColor(skip.color)
                                .labelStyle(.iconOnly)
                                .padding(.horizontal, 5)
                                .padding(.vertical, 3)
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
            Text(rowTitle)
                .font(.caption)
        }
    }
    
    init(for times: [Time], _ vm: ViewModel, _ task: TaskItem, _ taskExpanded: Binding<TaskItem?>, duration: Binding<Int>) {
        self.times = times
        self.task = task
        self.vm = vm
        _taskExpanded = taskExpanded
        _timeBlockDuration = duration
        if times == Time.days {
            rowTitle = "Schedule"
        } else {
            rowTitle = "Skip"
        }
    }
}
