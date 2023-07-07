//
//  TimeLengthStepper.swift
//  TaskTamer
//
//  Created by Cory Tripathy on 7/7/23.
//

import SwiftUI

struct TimeLengthStepper: View {
    @Binding var sliderValue: Int
    let geo: GeometryProxy
    @ScaledMetric(relativeTo: .body) var scaledPadding: CGFloat = 10
    var body: some View {
        HStack {
            Button {
                print("ah")
            } label: {
                ZStack {
                    label
                        .opacity(0.0)
                    Image(systemName: "minus")
                        .fontWeight(.regular)
                        .frame(width: geo.size.width / 5)
                }
            }
            Divider()
            label
                .frame(width: geo.size.width / 5)
            Divider()
            Button {
                print("ah")
            } label: {
                ZStack {
                    label
                        .opacity(0.0)
                    Image(systemName: "plus")
                        .fontWeight(.regular)
                        .frame(width: geo.size.width / 5)
                }
            }
        }
        .padding(.vertical, scaledPadding * 0.5)
        .background {
            RoundedRectangle(cornerRadius: 5)
                .foregroundColor(Color("StepperBackground"))
        }
        
    }
    var label: some View {
        VStack {
            Text("\(sliderValue)")
            Text("hours")
                .foregroundColor(.secondary)
                .font(.caption)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
        }
    }
}

struct TimeLengthStepper_Previews: PreviewProvider {
    static var previews: some View {
        GeometryReader { geo in
            TimeLengthStepper(sliderValue: .constant(15), geo: geo)
        }
    }
}
