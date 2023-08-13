//
//  UndoButtonView.swift
//  Chessy
//
//  Created by Yasha Serhiienko on 26.07.2023.
//

import SwiftUI

struct UndoButtonView<ChessGame: Game>: View {
    @EnvironmentObject var gameVM: GameViewModel<ChessGame>
    @State private var rotations = 0.0
    @GestureState var press = false
    @State private var timer: Timer?
    @AppStorage("shouldRotate") var shouldRotate: Bool = false

    var body: some View {
        Button {
            if let isValid = timer?.isValid, isValid {
                timer?.invalidate()
            } else {
                if gameVM.lastMove != nil {
                    gameVM.undoLastMove()
                    withAnimation(.spring(response: 0.3, dampingFraction: 1)) {
                        rotations += 1
                    }
                }
            }
        } label: {
            Image(systemName: "arrow.counterclockwise")
                .resizable()
                .foregroundColor(.primary)
                .aspectRatio(contentMode: .fit)
                .padding(8)
                .rotationEffect(Angle(
                    degrees: -360 * rotations + (shouldRotate && gameVM.turn == .black ? 180 : 0)
                ))
        }
        .simultaneousGesture(
            LongPressGesture(minimumDuration: 0.75)
                .onEnded { _ in
                    timer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: true) { _ in
                        if gameVM.lastMove != nil {
                            gameVM.undoLastMove()
                            withAnimation(.spring(response: 0.3, dampingFraction: 1)) {
                                rotations += 1
                            }
                        }
                    }
                }
        )
        .frame(width: 40, height: 40)
        .glassView()
    }
}
