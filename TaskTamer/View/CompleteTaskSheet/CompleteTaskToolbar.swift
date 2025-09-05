//
//  CompleteTaskToolbar.swift
//  TaskTamer
//
//  Created by Cory Tripathy on 7/6/23.
//

import SwiftUI

struct CompleteTaskToolbar: View {
    @ObservedObject var vm: ViewModel
    var body: some View {
        Button {
            vm.showingPreviousTaskSheet = true
        } label: {
            if vm.incompleteTasks.isEmpty {
                Label("Complete Tasks", systemImage: "calendar.badge.checkmark")
            } else {
                Label("Complete Tasks", systemImage: "calendar.badge.exclamationmark")
                .symbolRenderingMode(.palette)
                .foregroundStyle(Color.red,Color.accentColor,Color.primary)
            }
        }
    }
    init(_ vm: ViewModel) {
        self.vm = vm
    }
}

struct CompleteTaskToolbar_Previews: PreviewProvider {
    static var previews: some View {
        CompleteTaskToolbar(ViewModel())
    }
}
