//
//  PreferredTimeBlocks.swift
//  TaskTamer
//
//  Created by Cory Tripathy on 7/7/23.
//

import SwiftUI

struct PreferredTimeBlocks: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var vm: ViewModel
    @State var morningStart: Date
    @State var morningEnd: Date
    @State var afternoonStart: Date
    @State var afternoonEnd: Date
    @State var eveningStart: Date
    @State var eveningEnd: Date
    @State var timeBlockDuration: Int
    
    @State var invalidTimes = false
    
    var body: some View {
        GeometryReader { geo in
            Form {
                Section("Morning Time Block") {
                    DatePicker("Start", selection: $morningStart, displayedComponents: .hourAndMinute)
                    DatePicker("End", selection: $morningEnd, displayedComponents: .hourAndMinute)
                }
                Section("Afternoon Time Block") {
                    DatePicker("Start", selection: $afternoonStart, displayedComponents: .hourAndMinute)
                    DatePicker("End", selection: $afternoonEnd, displayedComponents: .hourAndMinute)
                }
                Section("Evening Time Block") {
                    DatePicker("Start", selection: $eveningStart, displayedComponents: .hourAndMinute)
                    DatePicker("End", selection: $eveningEnd, displayedComponents: .hourAndMinute)
                }
                Section("Default Time Block Duration") {
                    HStack {
                        Spacer()
                        TimeLengthStepper(sliderValue: $timeBlockDuration, geo: geo)
                        Spacer()
                    }
                }
                .listStyle(.plain)
                .buttonStyle(BorderlessButtonStyle())
                .onAppear {
                    UIDatePicker.appearance().minuteInterval = 15
                    load()
                }
                HStack {
                    Button {
                        reset()
                    } label: {
                        HStack {
                            Spacer()
                            Text("Reset")
                                .foregroundColor(.red)
                            Spacer()
                        }
                    }
                    .buttonStyle(.bordered)
                    Spacer()
                    Button {
                        save()
                    } label: {
                        HStack {
                            Spacer()
                            Text("Save")
                            Spacer()
                        }
                    }
                    .buttonStyle(.bordered)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .alert("Time Blocks must not overlap.", isPresented: $invalidTimes) {
                Button("Ok") { invalidTimes = false }
            }
        }
    }
    func save() {
        if morningStart > morningEnd || morningEnd > afternoonStart || afternoonStart > afternoonEnd || afternoonEnd > eveningStart || eveningStart > eveningEnd {
            invalidTimes = true
        } else {
            vm.morningStartTime = morningStart
            vm.morningEndTime = morningEnd
            vm.afternoonStartTime = afternoonStart
            vm.afternoonEndtime = afternoonEnd
            vm.eveningStartTime = eveningStart
            vm.eveningEndTime = eveningEnd
            vm.timeBlockDuration = timeBlockDuration
            vm.refreshTasks()
            dismiss()
        }
    }
    func reset() {
        vm.resetTimeBlocks()
        morningStart = vm.morningStartTime
        morningEnd = vm.morningEndTime
        afternoonStart = vm.afternoonStartTime
        afternoonEnd = vm.afternoonEndtime
        eveningStart = vm.eveningStartTime
        eveningEnd = vm.eveningEndTime
        timeBlockDuration = 15
    }
    init(_ vm: ViewModel) {
        self.vm = vm
        _morningStart = State<Date>.init(initialValue: vm.morningStartTime)
        _morningEnd = State<Date>.init(initialValue: vm.morningEndTime)
        _afternoonStart = State<Date>.init(initialValue: vm.afternoonStartTime)
        _afternoonEnd = State<Date>.init(initialValue: vm.afternoonEndtime)
        _eveningStart = State<Date>.init(initialValue: vm.eveningStartTime)
        _eveningEnd = State<Date>.init(initialValue: vm.eveningEndTime)
        _timeBlockDuration = State<Int>.init(initialValue: vm.timeBlockDuration)
        load()
    }
    func load() {
        morningStart = vm.morningStartTime
        morningEnd = vm.morningEndTime
        afternoonStart = vm.afternoonStartTime
        afternoonEnd = vm.afternoonEndtime
        eveningStart = vm.eveningStartTime
        eveningEnd = vm.eveningEndTime
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        PreferredTimeBlocks(ViewModel())
    }
}
