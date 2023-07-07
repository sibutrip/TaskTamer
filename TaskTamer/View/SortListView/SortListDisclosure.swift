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
    
    @Binding var taskExpanded: TaskItem?
    @Binding var taskDeleting: TaskItem?
    @State var deleteModeEnabled = false
    @State var fullSwipeDelete = false
    
    @State var xOffset: Double = 0
    @State var yFrame: Double = 1
    
    var body: some View {
        Group {
            Button {
                taskDeleting = nil
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
                LazyVStack {
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
                    .offset(x: min(-xOffset,0))
                    Divider()
                        .padding(.leading)
                }
                .padding(.top, scaledPadding)
                .overlay {
                    HStack {
                        Color.clear
                        Button {
                            if deleteModeEnabled {
                                delete()
                            }
                        } label: {
                            Rectangle()
                                .foregroundColor(.red)
                                .frame(width: max(xOffset, 0))
                                .overlay {
                                    HStack {
                                        Text("Delete")
                                            .foregroundColor(.white)
                                            .lineLimit(1)
                                            .minimumScaleFactor(0.1)
                                            .padding(fullSwipeDelete ? scaledPadding : 0)
                                        
                                        if fullSwipeDelete {
                                            Spacer()
                                        }
                                    }
                                }
                        }
                    }
                }
                .animation(.default, value: taskDeleting)
                .gesture(DragGesture()
                    .onChanged { value in
                        taskDeleting = task
                        withAnimation {
                            taskExpanded = nil
                        }
                        if deleteModeEnabled {
                            if value.translation.width > 0 {
                                xOffset = (-value.translation.width) + geo.size.width / 5
                            } else {
                                xOffset = (-value.translation.width + geo.size.width / 5)
                            }
                        } else {
                            if value.translation.width < 0 {
                                xOffset = abs(value.translation.width)
                            }
                        }
                        if xOffset > geo.size.width / 2 {
                            withAnimation { fullSwipeDelete = true }
                        } else {
                            withAnimation { fullSwipeDelete = false }
                        }
                    }
                    .onEnded { value in
                        if fullSwipeDelete {
                            delete()
                            return
                        }
                        withAnimation {
                            if -value.predictedEndTranslation.width > geo.size.width / 5 {
                                xOffset = geo.size.width / 5
                                deleteModeEnabled = true
                                return
                            }
                            xOffset = .zero
                            deleteModeEnabled = false
                            taskDeleting = nil
                        }
                    }
                )
            }
            .buttonStyle(.plain)
            .onChange(of: taskDeleting) { newValue in
                if newValue != task {
                    withAnimation {
                        if !fullSwipeDelete {
                            withAnimation { xOffset = 0 }
                            deleteModeEnabled = false
                        }
                    }
                }
            }
            
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
        .scaleEffect(y: yFrame)
    }
    
    func delete() {
        deleteModeEnabled = false
        withAnimation(.easeIn(duration: 0.25)) { xOffset = 0 }
        withAnimation(.easeIn(duration: 0.25)) { yFrame = 0 }
        vm.tasks.removeAll { $0 == task }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            yFrame = 1
            taskDeleting = nil
        }
    }
    
    init(_ vm: ViewModel, _ index: Int, _ taskExpanded: Binding<TaskItem?>, _ geo: GeometryProxy, _ taskDeleting: Binding<TaskItem?>) {
        self.vm = vm
        self.task = vm.unsortedTasks[index]
        self.geo = geo
        _taskExpanded = taskExpanded
        _taskDeleting = taskDeleting
    }
}
