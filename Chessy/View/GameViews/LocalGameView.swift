//
//  SinglePlayerGameView.swift
//  Chessy
//
//  Created by Yasha Serhiienko on 13.08.2023.
//

import SwiftUI

struct LocalGameView<ViewModel: ViewModelProtocol>: View {

    @EnvironmentObject private var vm: ViewModel

    @State private var isAlertPresented = false
    @AppStorage("shouldUndoMove") private var shouldUndoMove: Bool = false
    @AppStorage("shouldUpdateGame") private var shouldUpdateGame: Bool = false
    @Environment(\.verticalSizeClass) private var sizeClass

    private let fenInputView = FenInputView<ClassicGame>()
    private let gameView = GameView<ViewModel>()

    var body: some View {
        VStack(spacing: 0) {
            gameView
                .onShake { isAlertPresented.toggle() }
        }
        .customBackground()
        .alert("Reset game?", isPresented: $isAlertPresented, actions: {
            Button(role: .destructive) {
                vm.updateGame(with: ClassicGame(board: Board()))
            } label: {
                Text("Reset")
            }
        }, message: {
            Text("You will lose current game progress")
        })
        .onReceive(vm.whiteTime) {
            if let seconds = $0 {
                UserDefaults.standard.set(seconds, forKey: "whiteTime")
            }
        }
        .onReceive(vm.blackTime) {
            if let seconds = $0 {
                UserDefaults.standard.set(seconds, forKey: "blackTime")
            }
        }
        .onChange(of: shouldUndoMove) { _ in
            if shouldUndoMove {
                shouldUndoMove = false
                vm.undoLastMove()
            }
        }
        .onChange(of: shouldUpdateGame) { _ in
            if shouldUpdateGame {
                shouldUpdateGame = false
                isAlertPresented.toggle()
            }
        }
        .onDisappear {
            if let userDefaults = UserDefaults(suiteName: "group.com.yasha424.ChessyChess") {
                userDefaults.set(vm.fen.value, forKey: "fen")
            }
        }
    }
}
