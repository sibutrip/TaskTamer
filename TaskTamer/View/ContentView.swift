//
//  ContentView.swift
//  ADHDBrain
//
//  Created by Cory Tripathy on 4/30/23.
//

import SwiftUI

struct ContentView: View {
    @StateObject var vm = ViewModel()
    var body: some View {
        TabView {
            SortListView(vm: vm)
                .tabItem {
                    Label("Sort", systemImage: "calendar")
                }
            AllTasksView(vm: vm)
                .tabItem {
                    Label("All", systemImage: "tray.full")
                }
        }
        .transition(.slide)
        .animation(.default, value: vm.tasks)
        .sheet(isPresented: $vm.showingPreviousTaskSheet) {
            PreviousTaskSheet(vm)
        }
        .sheet(isPresented: $vm.showingSettingsSheet) {
            SettingsSheet()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
