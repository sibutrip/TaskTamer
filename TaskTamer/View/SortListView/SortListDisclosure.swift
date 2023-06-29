//
//  SortListDisclosure.swift
//  ADHDBrain
//
//  Created by Cory Tripathy on 5/31/23.
//

import Foundation
import SwiftUI

struct SortListDisclosure: View {
    @Environment(\.dynamicTypeSize) var dynamicTypeSize
    @ObservedObject var vm: ViewModel
    
    @ScaledMetric(relativeTo: .body) var scaledPadding: CGFloat = 10
    
    let task: TaskItem
    let geo: GeometryProxy
    
    @Environment(\.editMode) var editMode
    @Binding var taskExpanded: TaskItem?
    @State var deleteModeEnabled = false
    
    @State var offset: Double = 0
    
    var body: some View {
        Button {
            if taskExpanded != task {
                withAnimation {
                    taskExpanded = task
                }
            } else {
                withAnimation {
                    taskExpanded = nil
                }
            }
        } label: {
            VStack {
                HStack {
                    Text(task.name)
                    Spacer()
                    Image(systemName: "chevron.forward")
                        .fontWeight(.medium)
                        .rotationEffect(Angle(degrees: taskExpanded == task ? 90 : 0))
                        .foregroundColor(.accentColor)
                }
                .padding(.horizontal)
                .contentShape(Rectangle())
                .offset(x: taskExpanded == task ? -offset : 0)
                Divider()
                    .padding(.leading)
            }
            .padding(.top, scaledPadding)
            .overlay {
                HStack {
                    Color.clear
                    Rectangle()
                        .foregroundColor(.red)
                        .frame(width: offset)
                        .overlay {
                            Text("Delete")
                                .foregroundColor(.white)
                                .lineLimit(1)
                                .minimumScaleFactor(0.1)
                        }
                }
            }
            .animation(.default, value: deleteModeEnabled)
            .gesture(DragGesture()
                .onChanged { value in
                    if deleteModeEnabled {
                        offset = abs(value.translation.width) + geo.size.width / 5
                        return
                    }
                    if value.translation.width < 0 {
                        offset = abs(value.translation.width)
                    }
                }
                .onEnded { value in
                    withAnimation {
                        if offset > geo.size.width / 5 {
                            offset = geo.size.width / 5
                            deleteModeEnabled = true
                            return
                        }
                        offset = .zero
                        deleteModeEnabled = false
                    }
                }
            )
        }
        .buttonStyle(.plain)
        
        if taskExpanded == task {
            VStack {
                let layout = dynamicTypeSize > .xxLarge ? AnyLayout(VStackLayout(alignment: .center)) : AnyLayout(HStackLayout(alignment: .center))
                layout {
                    DisclosureRow(for: Time.skips, vm, task, $taskExpanded)
                    Spacer()
                    DisclosureRow(for: Time.days, vm, task, $taskExpanded)
                }
                Divider()
            }
            .padding(.horizontal, 30)
            .padding(.top, scaledPadding)
            .scaleEffect(taskExpanded == task ? 1 : 0.1)
            .animation(.default, value: taskExpanded)
        }
    }
    
    init(_ vm: ViewModel, _ index: Int, _ taskExpanded: Binding<TaskItem?>, _ geo: GeometryProxy) {
        self.vm = vm
        self.task = vm.unsortedTasks[index]
        _taskExpanded = taskExpanded
        self.geo = geo
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
