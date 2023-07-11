//
//  SortList.swift
//  TaskTamer
//
//  Created by Cory Tripathy on 7/11/23.
//

import SwiftUI

struct SortList: View {
    @Environment(\.dynamicTypeSize) var dynamicTypeSize
    @ObservedObject var vm: ViewModel
    
    @ScaledMetric(relativeTo: .body) var scaledPadding: CGFloat = 10
    
    let task: TaskItem
    let geo: GeometryProxy
    
    @Binding var taskDeleting: TaskItem?
    @State var deleteModeEnabled = false
    @State var fullSwipeDelete = false
    @State var timeBlockDuration: Int
    
    @State var xOffset: Double = 0
    @State var yFrame: Double = 1
    
    var body: some View {
            LazyVStack(spacing: 0) {
                HStack {
                    Text(task.name)
                    Spacer()
                }
                .padding(.horizontal)
                .contentShape(Rectangle())
                .offset(x: min(-xOffset,0))
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
            .gesture(DragGesture(coordinateSpace: .global)
                .onChanged { value in
                    withAnimation { taskDeleting = task }
                    print(value.translation.width)
                    if value.translation.width + geo.size.width / 20 > 0 && !deleteModeEnabled { return }
                    let translation = -value.translation.width - geo.size.width / 20
                    withAnimation {
                        //                            taskExpanded = nil
                        if deleteModeEnabled {
                            if value.translation.width > 0 {
                                xOffset = (-value.translation.width) + geo.size.width / 5
                            } else {
                                xOffset = (-value.translation.width + geo.size.width / 5)
                            }
                        } else {
                            if value.translation.width < 0 {
                                xOffset = abs(translation)
                            }
                        }
                        if xOffset > geo.size.width / 2 {
                            fullSwipeDelete = true
                        } else {
                            fullSwipeDelete = false
                        }
                    }
                }
                .onEnded { value in
                    if fullSwipeDelete {
                        delete()
                        taskDeleting = nil
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
    
    init(_ vm: ViewModel, _ task: TaskItem, _ geo: GeometryProxy, _ taskDeleting: Binding<TaskItem?>) {
        self.vm = vm
        self.task = task
        self.geo = geo
        _taskDeleting = taskDeleting
        _timeBlockDuration = State<Int>.init(initialValue: vm.timeBlockDuration)
    }
}


struct SortList_Previews: PreviewProvider {
    static var previews: some View {
        GeometryReader { geo in
            SortList(ViewModel(), TaskItem(name: "some thing"), geo, .constant(nil))
        }
    }
}
