//
//  SwipeGesture.swift
//  ADHDBrain
//
//  Created by Cory Tripathy on 4/30/23.
//

import Foundation
import SwiftUI

struct SwipeGesture: ViewModifier {
    let task: TaskItem
    
    let geo: GeometryProxy
        
    @StateObject var dragManager = DragManager()
    
    var offset: CGSize {
        get {
            var dragOffset = dragManager.offset
            if DragManager.sortDidFail {
                dragOffset = .zero
                dragManager.zeroOffsets()
            }
            return dragOffset
        }
        nonmutating set {
            dragManager.offset = newValue
        }
    }
    
    @State private var dropPreference: DropPreference?
    @State private var dropState: TimeSelection = .noneSelected
    
    @State private var dragPreference = DragPreference()
    @State private var dragState: TimeSelection = .noneSelected
    @State private var isDragging: Bool = false
    
    @State private var dismissKeyboardPreference: DismissKeyboardPreference?
    @State private var dismissKeyboard: SortDragView.FocusedField? = .showKeyboard
    
    @State var locationWidth: CGFloat = .zero
    @State var locationHeight: CGFloat = .zero
    
    func cancelKeyboardGesture() -> _ChangedGesture<DragGesture> {
        DragGesture().onChanged { _ in
            dismissKeyboard = nil
        }
    }
    
    func dragGesture(top: CGFloat, center: CGFloat, bottom: CGFloat, leading: CGFloat, trailing: CGFloat) -> _EndedGesture<_ChangedGesture<DragGesture>> {
        return DragGesture()
            .onChanged { value in
                print(top)
                isDragging = true
                offset = value.translation
                locationHeight = value.location.y
                locationWidth = value.location.x
                if locationWidth <  leading {
                    // leading edge of screen
                    if locationHeight < top {
                        dragState = .skip1
                    } else if locationHeight < center {
                        dragState = .skip3
                    } else {
                        dragState = .skip7
                    }
                } else if locationWidth < trailing {
                    // middle of screen
                    dragState = .noneSelected
                } else {
                    // trailing edge of screen
                    if locationHeight < top {
                        dragState = .morning
                    } else if locationHeight < center {
                        dragState = .afternoon
                    } else {
                        dragState = .evening
                    }
                }
            }
            .onEnded { value in
                dropState = dragState
                dragState = .noneSelected
                isDragging = false
                if dropState == .noneSelected {
                    offset = .zero
                }
            }
    }
    
    lazy var dragGesture = DragGesture()
    
    let top: CGFloat
    let center: CGFloat
    let bottom: CGFloat
    let leading: CGFloat
    let trailing: CGFloat
    
    func body(content: Content) -> some View {
        content
            .offset(offset)
            .gesture(dragGesture(top: top, center: center, bottom: bottom, leading: leading, trailing: trailing))
            .preference(key: DropPreference.self, value: DropTask(task: task, timeSelection: dropState))
            .preference(key: DragPreference.self, value: DragTask(isDragging: isDragging, timeSelection: dragState, keyboardSelection: dismissKeyboard))
            .preference(key: DismissKeyboardPreference.self, value: dismissKeyboard)

            .animation(.easeOut, value: isDragging)
    }
    
    init(_ geo: GeometryProxy, with task: TaskItem) {
        self.task = task
        self.geo = geo
        top = geo.size.height / 3
        center = 2 * geo.size.height / 3
        bottom = geo.size.height
        leading = geo.size.height / 3 - geo.size.height / 4
        trailing = geo.size.width - geo.size.height / 3 + geo.size.height / 4
    }
}
