//
//  SettingsToolbar.swift
//  TaskTamer
//
//  Created by Cory Tripathy on 7/7/23.
//

import SwiftUI

struct SettingsToolbar: View {
    @ObservedObject var vm: ViewModel
    var body: some View {
        Button {
            vm.showingSettingsSheet = true
        } label: {
            Label("Settings", systemImage: "gear")
        }
    }
    init(_ vm: ViewModel) {
        self.vm = vm
    }
}

struct SettingsToolbar_Previews: PreviewProvider {
    static var previews: some View {
        SettingsToolbar(ViewModel())
    }
}
