//
//  TimerView.swift
//  Chessy
//
//  Created by Yasha Serhiienko on 24.07.2023.
//

import SwiftUI

struct TimerView<ChessGame>: View where ChessGame: Game {
    @ObservedObject var game: ChessGame
    let color: PieceColor
    
    var body: some View {
        let time = (color == .white ? game.whiteTime : game.blackTime) ?? 0
        ZStack {
            Text("\(time / 60):\(time % 60 < 10 ? "0\(time % 60)" : "\(time % 60)")")
                .frame(width: 80, height: 40)
                .font(.title.monospaced())
                .rotationEffect(Angle(degrees: game.turn == .white ? 0 : 180))
        }
        .glassView()
        .onTapGesture {
            game.addTime(for: color)
        }
    }
}
