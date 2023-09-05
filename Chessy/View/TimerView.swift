//
//  TimerView.swift
//  Chessy
//
//  Created by Yasha Serhiienko on 24.07.2023.
//

import SwiftUI

struct TimerView<ChessGame: Game>: View {

    @EnvironmentObject private var vm: GameViewModel<ChessGame>
    let color: PieceColor
    @State private var time: Int = 0
    @State private var turn: PieceColor = .white

    @Environment(\.horizontalSizeClass) private var sizeClass

    @AppStorage("shouldRotate") private var shouldRotate: Bool = false

    var body: some View {
        ZStack {
            Text("\(time / 60):\(time % 60 < 10 ? "0\(time % 60)" : "\(time % 60)")")
                .frame(height: 40)
                .font(.title.monospaced())
                .padding(.horizontal, 8)
                .opacity(turn == color ? 1.0 : 0.5)
        }
        .rotationEffect(Angle(
            degrees: shouldRotate && turn == .black ? 180 : 0
        ))
        .glassView()
        .onTapGesture {
            vm.addTime(for: color)
        }
        .onReceive(color == .white ? vm.whiteTime : vm.blackTime) {
            if let seconds = $0 {
                time = seconds
            }
        }
        .onAppear {
            time = (color == .white ? vm.whiteTime.value : vm.blackTime.value) ?? 0
            turn = vm.turn.value
        }
        .onReceive(vm.turn) {
            turn = $0
        }
    }
}
