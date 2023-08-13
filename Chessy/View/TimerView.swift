//
//  TimerView.swift
//  Chessy
//
//  Created by Yasha Serhiienko on 24.07.2023.
//

import SwiftUI

struct TimerView<ChessGame: Game>: View {
    @EnvironmentObject var gameVM: GameViewModel<ChessGame>
    let color: PieceColor
    @State var time: Int = 30

    @Environment(\.horizontalSizeClass) var sizeClass

    @AppStorage("shouldRotate") var shouldRotate: Bool = false
    @AppStorage("whiteTime") var whiteTime: Int = 30
    @AppStorage("blackTime") var blackTime: Int = 30

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
        .onChange(of: color == .white ? gameVM.whiteTime : gameVM.blackTime) { _ in
            time = (color == .white ? gameVM.whiteTime : gameVM.blackTime) ?? 0
            whiteTime = gameVM.whiteTime ?? 30
            blackTime = gameVM.blackTime ?? 30
        }
        .onAppear {
            gameVM.setTime(seconds: whiteTime, for: .white)
            gameVM.setTime(seconds: blackTime, for: .black)
            time = color == .white ? whiteTime : blackTime
            gameVM.startTimer()
        }
    }
}
