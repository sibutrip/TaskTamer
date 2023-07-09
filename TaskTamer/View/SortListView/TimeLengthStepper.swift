//
//  TimeLengthStepper.swift
//  TaskTamer
//
//  Created by Cory Tripathy on 7/7/23.
//

import SwiftUI

struct TimeLengthStepper: View {
    let increments: CGFloat
    let geo: GeometryProxy
    @Environment(\.dynamicTypeSize) var textSize
    @Binding var sliderValue: Int
    @ScaledMetric(relativeTo: .body) var scaledPadding: CGFloat = 10
    @State var numberOfDragTicks = 0
    
    var hours: String { String(sliderValue / 60) }
    var mins: String { String(sliderValue % 60) }
    
    init(sliderValue: Binding<Int>, geo: GeometryProxy) {
        _sliderValue = sliderValue
        self.geo = geo
        increments = geo.size.width / 20
    }
    
    var body: some View {
        HStack(spacing: 0) {
            Button {
                let newValue = sliderValue - 15
                withAnimation(Animation.easeInOut(duration: 0.1)) { sliderValue = newValue
                }
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
                .padding(.trailing, scaledPadding)
            label
                .gesture(DragGesture(coordinateSpace: .global)
                    .onChanged { value in
                        let location = value.translation.width - CGFloat(numberOfDragTicks) * increments
                        var newSliderValue = sliderValue
                        if location > increments {
                            newSliderValue += 15
                            numberOfDragTicks += 1
                        } else if location < -increments {
                            newSliderValue -= 15
                            numberOfDragTicks -= 1
                        }
                        if newSliderValue <= 240 && newSliderValue > 0 {
                            withAnimation(Animation.easeInOut(duration: 0.1)) {
                                sliderValue = newSliderValue
                            }
                        }
                    }
                    .onEnded { _ in
                        numberOfDragTicks = 0
                    }
                )
                .frame(width: geo.size.width / 4)
            Divider()
                .padding(.leading, scaledPadding)
            Button {
                let newValue = sliderValue + 15
                withAnimation(Animation.easeInOut(duration: 0.2 )) { sliderValue = newValue
                }
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
                            .minimumScaleFactor(0.1)
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
                            .minimumScaleFactor(0.1)
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
