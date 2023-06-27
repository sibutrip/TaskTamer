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
            Group {
                SortListView(vm: vm)
                    .tabItem {
                        Label("Disclosure", systemImage: "calendar")
                    }
                SortDragView(vm: vm)
                    .tabItem {
                        Label("Drag", systemImage: "calendar")
                    }
                SortSwipeView(vm: vm)
                    .tabItem {
                        Label("Swipe", systemImage: "calendar")
                    }
            }
            .navigationTitle("Sort Tasks")
            AllTasksView(vm: vm)
                .tabItem {
                    Label("All", systemImage: "tray.full")
                }
        }
        .transition(.slide)
        .animation(.default, value: vm.tasks)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
