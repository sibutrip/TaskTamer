//
//  TimeLengthStepper.swift
//  TaskTamer
//
//  Created by Cory Tripathy on 7/7/23.
//

import SwiftUI

struct TimeLengthStepper: View {
    @Environment(\.dynamicTypeSize) var textSize
    @Binding var sliderValue: Int
    let geo: GeometryProxy
    @ScaledMetric(relativeTo: .body) var scaledPadding: CGFloat = 10
    @State var hours: String
    @State var mins: String
    init(sliderValue: Binding<Int>, geo: GeometryProxy) {
        _sliderValue = sliderValue
        self.geo = geo
        _hours = State<String>.init(initialValue: String(sliderValue.wrappedValue / 60))
        _mins = State<String>.init(initialValue: String(sliderValue.wrappedValue % 60))
    }
    
    func update(with newValue: Int) {
        let mins = newValue % 60
        let hours = newValue / 60
        withAnimation(Animation.easeInOut(duration: 0.2)) {
            self.hours = String(hours)
            self.mins = String(mins)
        }
        self.sliderValue = newValue
    }
    
    
    
    var body: some View {
        HStack {
            Button {
                let newValue = sliderValue - 15
                update(with: newValue)
            } label: {
                ZStack {
                    Text("")
                        .padding(.vertical, scaledPadding * 0.5)
                        .opacity(0.0)
                    Image(systemName: "minus")
                        .fontWeight(.regular)
                        .frame(width: geo.size.width / 5)
                }
            }
            .disabled(sliderValue == 15)
            Divider()
            label
                .frame(width: geo.size.width / 4)
            Divider()
            Button {
                let newValue = sliderValue + 15
                update(with: newValue)
            } label: {
                ZStack {
                    Text("")
                        .padding(.vertical, scaledPadding * 0.5)
                        .opacity(0.0)
                    Image(systemName: "plus")
                        .fontWeight(.regular)
                        .frame(width: geo.size.width / 5)
                }
            }
            .disabled(sliderValue == 240)
        }
        .padding(.vertical, scaledPadding * 0.5)
        .background {
            RoundedRectangle(cornerRadius: 5)
                .foregroundColor(Color("StepperBackground"))
        }
        
    }
    var label: some View {
        let layout = textSize < .xLarge ? AnyLayout(HStackLayout()) : AnyLayout(VStackLayout())
        return layout {
            Group {
                if hours != "0" {
                    VStack {
                        Text("\(hours)")
                            .lineLimit(1)
                        Text(hours == "1" ? "hour" : "hours")
                            .foregroundColor(.secondary)
                            .font(.caption)
                            .lineLimit(1)
                    }
                }
                if mins != "0" {
                    VStack {
                        Text("\(mins)")
                            .lineLimit(1)
                        Text("minutes")
                            .foregroundColor(.secondary)
                            .font(.caption)
                            .lineLimit(1)
                    }
                }
            }
            .transition(.scale)
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
