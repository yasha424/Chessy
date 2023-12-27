//
//  RangeSlider.swift
//  Chessy
//
//  Created by Yasha Serhiienko on 18.09.2023.
//

import Combine
import SwiftUI

@propertyWrapper
struct SliderValue {
    var value: Double

    init(wrappedValue: Double) {
        self.value = wrappedValue
    }

    var wrappedValue: Double {
        get { value }
        set { value = min(max(0.0, newValue), 1.0) }
    }
}

class SliderHandle: ObservableObject {
    let sliderWidth: CGFloat
    let sliderHeight: CGFloat
    let sliderValueStart: Double
    let sliderValueRange: Double
    var diameter: CGFloat = 40
    var startLocation: CGPoint

    @Published var currentPercentage: SliderValue
    @Published var onDrag: Bool
    @Published var currentLocation: CGPoint

    init(sliderWidth: CGFloat, sliderHeight: CGFloat,
         sliderValueStart: Double, sliderValueEnd: Double, startPercentage: SliderValue) {
        self.sliderWidth = sliderWidth
        self.sliderHeight = sliderHeight
        self.sliderValueStart = sliderValueStart
        self.sliderValueRange = sliderValueEnd - sliderValueStart

        let startLocation = CGPoint(
            x: (CGFloat(startPercentage.wrappedValue)/1.0)*sliderWidth,
            y: sliderHeight/2
        )

        self.startLocation = startLocation
        self.currentLocation = startLocation
        self.currentPercentage = startPercentage
        self.onDrag = false
    }

    lazy var sliderDragGesture: _EndedGesture<_ChangedGesture<DragGesture>>  = DragGesture()
        .onChanged { value in
            self.onDrag = true
            let dragLocation = value.location
            self.restrictSliderBtnLocation(dragLocation)
            self.currentPercentage.wrappedValue = Double(self.currentLocation.x / self.sliderWidth)
        }.onEnded { _ in
            self.onDrag = false
        }

    private func restrictSliderBtnLocation(_ dragLocation: CGPoint) {
        if dragLocation.x > CGPoint.zero.x && dragLocation.x < sliderWidth {
            calcSliderBtnLocation(dragLocation)
        }
    }

    private func calcSliderBtnLocation(_ dragLocation: CGPoint) {
        if dragLocation.y != sliderHeight/2 {
            currentLocation = CGPoint(x: dragLocation.x, y: sliderHeight/2)
        } else {
            currentLocation = dragLocation
        }
    }

    var currentValue: Int {
        return Int(sliderValueStart + currentPercentage.wrappedValue * sliderValueRange)
    }
}

class CustomSlider: ObservableObject {
    let width: CGFloat = 300
    let lineWidth: CGFloat = 8
    let valueStart: Double
    let valueEnd: Double

    @Published var highHandle: SliderHandle
    @Published var lowHandle: SliderHandle

    @SliderValue var highHandleStartPercentage = 1.0
    @SliderValue var lowHandleStartPercentage = 0.0

    var anyCancellableHigh: AnyCancellable?
    var anyCancellableLow: AnyCancellable?

    init(start: Double, end: Double) {
        valueStart = start
        valueEnd = end

        highHandle = SliderHandle(
            sliderWidth: width,
            sliderHeight: lineWidth,
            sliderValueStart: valueStart,
            sliderValueEnd: valueEnd,
            startPercentage: _highHandleStartPercentage
        )

        lowHandle = SliderHandle(
            sliderWidth: width,
            sliderHeight: lineWidth,
            sliderValueStart: valueStart,
            sliderValueEnd: valueEnd,
            startPercentage: _lowHandleStartPercentage
        )

        anyCancellableHigh = highHandle.objectWillChange.sink { _ in
            self.objectWillChange.send()
        }
        anyCancellableLow = lowHandle.objectWillChange.sink { _ in
            self.objectWillChange.send()
        }
    }

    var percentagesBetween: String {
        return String(format: "%.2f", highHandle.currentPercentage.wrappedValue -
                      lowHandle.currentPercentage.wrappedValue)
    }

    var valueBetween: String {
        return String(format: "%.2f", highHandle.currentValue - lowHandle.currentValue)
    }
}
