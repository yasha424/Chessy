//
//  FilterOptionsView.swift
//  Chessy
//
//  Created by Yasha Serhiienko on 18.09.2023.
//

import SwiftUI

struct FilterOptionsView: View {
    enum FilterOption {
        case rating(min: Int, max: Int)
    }

    @Binding var isFilterSheetPresented: Bool

    @State var filterOptions: FilterOption = .rating(min: 0, max: 3000)
    @StateObject var slider = CustomSlider(start: 0, end: 3000)

    var body: some View {
        VStack {
            HStack {
                Spacer()
                Button {
                    filterOptions = .rating(
                        min: slider.lowHandle.currentValue,
                        max: slider.highHandle.currentValue
                    )
                    isFilterSheetPresented.toggle()
                } label: {
                    Text("Done")
                }
            }
            Spacer()
            HStack {
                Text(String(slider.lowHandle.currentValue))
                Spacer()
                Text(String(slider.highHandle.currentValue))
            }
            RangeSliderView(slider: slider)
            Spacer()
        }
    }
}
