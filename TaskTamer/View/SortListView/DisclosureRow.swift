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
    func displayedTimes(for time: TimeSelection) -> [Date] {
        let (startTime, endTime) = switch time {
        case .morning:
            (vm.morningStartTime, vm.morningEndTime)
        case .afternoon:
            (vm.afternoonStartTime, vm.afternoonEndtime)
        case .evening:
            (vm.eveningStartTime, vm.eveningEndTime)
        default:
            (Date(),Date())
        }
        var timeCounter = startTime
        var displayedTimes = [Date]()
        while timeCounter < endTime.addingTimeInterval(TimeInterval(timeBlockDuration * 60)) {
            displayedTimes.append(timeCounter)
            timeCounter = timeCounter.addingTimeInterval(TimeInterval(timeBlockDuration * 60))
        }
        return displayedTimes
    }
    
    let times: [Time]
    let rowTitle: String
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                ForEach(times) { time in
                    Button {
                        Haptic.medium()
                        Task {
                            _ = await vm.schedule(task: task, within: time.timeSelection, with: TimeInterval(timeBlockDuration * 60))
                            taskExpanded = nil
                        }
                    } label: {
                            if times == Time.days {
                                Label(time.name, systemImage: time.image)
                                    .foregroundColor(time.color)
                                    .labelStyle(.iconOnly)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 8)
                                    .contentShape(Rectangle())
                                    .contextMenu {
                                        ForEach(displayedTimes(for: time.timeSelection), id: \.self) { date in
                                            Button(date.formatted(date: .omitted, time: .shortened)) {
                                                Task {
                                                    await vm.schedule(task: task, within: time.timeSelection, with: TimeInterval(timeBlockDuration * 60))
                                                }
                                            }
                                        }
                                    }
                            } else {
                                Label(time.name, image: time.image)
                                    .foregroundColor(time.color)
                                    .labelStyle(.iconOnly)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 8)
                                    .contentShape(Rectangle())
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
