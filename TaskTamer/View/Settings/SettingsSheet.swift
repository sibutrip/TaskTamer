//
//  SettingsSheet.swift
//  TaskTamer
//
//  Created by Cory Tripathy on 7/7/23.
//

import SwiftUI

struct SettingsSheet: View {
    @ObservedObject var vm: ViewModel
    var body: some View {
        NavigationStack {
            Form {
                NavigationLink("Time Blocks") {
                    PreferredTimeBlocks(vm)
                }
//                NavigationLink("Preferred Time Blocks") {
//                    PreferredTimeBlocks()
//                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    init(_ vm: ViewModel) {
        self.vm = vm
    }
}

struct SettingsSheet_Previews: PreviewProvider {
    static var previews: some View {
        SettingsSheet(ViewModel())
    }
}
