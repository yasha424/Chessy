//
//  CapturePieceShape.swift
//  Chessy
//
//  Created by Yasha Serhiienko on 12.08.2023.
//

import SwiftUI

struct CapturePieceShape: Shape {

    func path(in rect: CGRect) -> Path {
        Path { path in
            path.move(to: CGPoint(x: rect.midX / 3, y: 0))
            path.addLine(to: CGPoint.zero)
            path.addLine(to: CGPoint(x: 0, y: rect.midY / 3))

            path.move(to: CGPoint(x: rect.maxX, y: rect.midY / 3))
            path.addLine(to: CGPoint(x: rect.maxX, y: 0))
            path.addLine(to: CGPoint(x: rect.maxX - rect.midX / 3, y: 0))

            path.move(to: CGPoint(x: rect.midX / 3, y: rect.maxY))
            path.addLine(to: CGPoint(x: 0, y: rect.maxY))
            path.addLine(to: CGPoint(x: 0, y: rect.maxY - rect.midY / 3))

            path.move(to: CGPoint(x: rect.maxX, y: rect.maxY - rect.midY / 3))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
            path.addLine(to: CGPoint(x: rect.maxX - rect.midX / 3, y: rect.maxY))
        }
    }

}
