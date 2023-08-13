//
//  GlassView.swift
//  Chessy
//
//  Created by Yasha Serhiienko on 22.07.2023.
//

import SwiftUI

struct GlassView: ViewModifier {

    var cornerRadius: CGFloat = 14

    func body(content: Content) -> some View {
        content
            .background(.ultraThinMaterial)
            .cornerRadius(cornerRadius)
            .shadow(color: .white.opacity(0.9), radius: 2, x: -1, y: -2)
            .shadow(color: .black.opacity(0.6), radius: 2, x: 2, y: 2)
    }
}
