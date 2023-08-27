//
//  TimerView.swift
//  Chessy
//
//  Created by Yasha Serhiienko on 24.07.2023.
//

import SwiftUI

struct TimerView<ChessGame: Game>: View {

    @EnvironmentObject private var gameVM: GameViewModel<ChessGame>
    let color: PieceColor
    @State private var time: Int = 0

    @Environment(\.horizontalSizeClass) private var sizeClass

    @AppStorage("shouldRotate") private var shouldRotate: Bool = false

    var body: some View {
        ZStack {
            Text("\(time / 60):\(time % 60 < 10 ? "0\(time % 60)" : "\(time % 60)")")
                .frame(height: 40)
                .font(.title.monospaced())
                .padding(.horizontal, 8)
                .opacity(gameVM.turn == color ? 1.0 : 0.5)
        }
        .rotationEffect(Angle(
            degrees: shouldRotate && gameVM.turn == .black ? 180 : 0
        ))
        .glassView()
        .onTapGesture {
            gameVM.addTime(for: color)
        }
        .onReceive(color == .white ? gameVM.whiteTime : gameVM.blackTime) {
            if let seconds = $0 {
                time = seconds
            }
        }
        .onAppear {
            time = (color == .white ? gameVM.whiteTime.value : gameVM.blackTime.value) ?? 0
        }
    }
}
