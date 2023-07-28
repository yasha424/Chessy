//
//  UndoButtonView.swift
//  Chessy
//
//  Created by Yasha Serhiienko on 26.07.2023.
//

import SwiftUI

struct UndoButtonView<ChessGame>: View where ChessGame: Game {
    let game: ChessGame
    @State var rotations = 0
    @Environment(\.horizontalSizeClass) var sizeClass

    var body: some View {
        Button {
            game.undoLastMove()
            withAnimation(.easeInOut) {
                rotations += 1
            }
        } label: {
            Image(systemName: "arrow.counterclockwise")
                .resizable()
                .foregroundColor(.white)
                .aspectRatio(contentMode: .fit)
                .padding(8)
                .rotationEffect(Angle(
                    degrees: -360 * Double(rotations)
                ))
        }
        .frame(width: 40, height: 40)
        .glassView()
    }
}
