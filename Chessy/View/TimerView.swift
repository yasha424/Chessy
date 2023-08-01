//
//  TimerView.swift
//  Chessy
//
//  Created by Yasha Serhiienko on 24.07.2023.
//

import SwiftUI

struct TimerView<ChessGame: Game>: View {
    @ObservedObject var gameVM: GameViewModel<ChessGame>
    let color: PieceColor

    @Environment(\.horizontalSizeClass) var sizeClass
    @Environment(\.shouldRotate) var shouldRotate: Bool

    var body: some View {
        let time = (color == .white ? gameVM.whiteTime : gameVM.blackTime) ?? 0
        ZStack {
            Text("\(time / 60):\(time % 60 < 10 ? "0\(time % 60)" : "\(time % 60)")")
                .frame(height: 40)
                .font(.title.monospaced())
                .padding([.leading, .trailing], 8)
        }
        .rotationEffect(Angle(
            degrees: shouldRotate && gameVM.turn == .black ? 180 : 0
        ))
        .glassView()
        .onTapGesture {
            gameVM.addTime(for: color)
        }
    }
}
