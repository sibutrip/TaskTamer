//
//  SettingsSheet.swift
//  TaskTamer
//
//  Created by Cory Tripathy on 7/7/23.
//

import SwiftUI

struct SettingsSheet: View {
    @Environment(\.dismiss) var dismiss
    @State var morningStart = TimeBlocks.shared.morningStartTime
    @State var morningEnd = TimeBlocks.shared.morningEndTime
    @State var afternoonStart = TimeBlocks.shared.afternoonStartTime
    @State var afternoonEnd = TimeBlocks.shared.afternoonEndtime
    @State var eveningStart = TimeBlocks.shared.eveningStartTime
    @State var eveningEnd = TimeBlocks.shared.eveningEndTime
    
    @State var invalidTimes = false
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Morning") {
                    DatePicker("Start", selection: $morningStart, displayedComponents: .hourAndMinute)
                    DatePicker("End", selection: $morningEnd, displayedComponents: .hourAndMinute)
                }
                Section("Afternoon") {
                    DatePicker("Start", selection: $afternoonStart, displayedComponents: .hourAndMinute)
                    DatePicker("End", selection: $afternoonEnd, displayedComponents: .hourAndMinute)
                }
                Section("Evening") {
                    DatePicker("Start", selection: $eveningStart, displayedComponents: .hourAndMinute)
                    DatePicker("End", selection: $eveningEnd, displayedComponents: .hourAndMinute)
                }
                .onAppear {
                    UIDatePicker.appearance().minuteInterval = 15
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
            .navigationTitle("Preferred Time Blocks")
            .alert("Time Blocks must not overlap.", isPresented: $invalidTimes) {
                Button("Ok") { invalidTimes = false }
            }
        }
    }
    func save() {
        if morningStart > morningEnd || morningEnd > afternoonStart || afternoonStart > afternoonEnd || afternoonEnd > eveningStart || eveningStart > eveningEnd {
            invalidTimes = true
        } else {
            TimeBlocks.shared.morningStartTime = morningStart
            TimeBlocks.shared.morningEndTime = morningEnd
            TimeBlocks.shared.afternoonStartTime = afternoonStart
            TimeBlocks.shared.afternoonEndtime = afternoonEnd
            TimeBlocks.shared.eveningStartTime = eveningStart
            TimeBlocks.shared.eveningEndTime = eveningEnd
            dismiss()
        }
    }
    func reset() {
        TimeBlocks.shared.reset()
        morningStart = TimeBlocks.shared.morningStartTime
        morningEnd = TimeBlocks.shared.morningEndTime
        afternoonStart = TimeBlocks.shared.afternoonStartTime
        afternoonEnd = TimeBlocks.shared.afternoonEndtime
        eveningStart = TimeBlocks.shared.eveningStartTime
        eveningEnd = TimeBlocks.shared.eveningEndTime
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsSheet()
    }
}
