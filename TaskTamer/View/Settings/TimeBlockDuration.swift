//
//  TimeBlockDuration.swift
//  TaskTamer
//
//  Created by Cory Tripathy on 7/8/23.
//

import SwiftUI

struct TimeBlockDuration: View {
    @ObservedObject var vm: ViewModel
    var body: some View {
        List {
            GeometryReader { geo in
                TimeLengthStepper(sliderValue: $vm.timeBlockDuration, geo: geo)
            }
        }
        .navigationTitle("Default Time Block Duration")
        .navigationBarTitleDisplayMode(.inline)
    }
    init(_ vm: ViewModel) {
        self.vm = vm
    }
}

struct TimeBlockDuration_Previews: PreviewProvider {
    static var previews: some View {
        TimeBlockDuration(ViewModel())
    }
}
