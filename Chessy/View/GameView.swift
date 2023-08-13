//
//  BoardView.swift
//  Chessy
//
//  Created by Yasha Serhiienko on 09.07.2023.
//

import SwiftUI

struct GameView<ChessGame: Game>: View {

    @EnvironmentObject var gameVM: GameViewModel<ChessGame>

    let boardView = BoardView<ChessGame>()
    let blackTimerView = TimerView<ChessGame>(color: .black)
    let whiteTimerView = TimerView<ChessGame>(color: .white)
    let undoButtonView = UndoButtonView<ChessGame>()

    var body: some View {
        ZStack {
            VStack {
                switch gameVM.state {
                case .checkmate(let color):
                    Text((color == .black ? "White" : "Black") + " won by checkmate!")
                        .padding([.leading, .trailing])
                        .frame(height: 40)
                        .glassView()
                        .transition(.move(edge: .top))
                case .stalemate:
                    Text("Stalemate!")
                        .padding([.leading, .trailing])
                        .frame(height: 40)
                        .glassView()
                        .transition(.move(edge: .top))
                default:
                    EmptyView()
                }

                Spacer()
            }
            .zIndex(3.0)
            .animation(.spring(response: 0.3), value: gameVM.state)

                VStack {
                    Spacer()

                    if gameVM.hasTimer {
                        HStack {
                            Spacer()

                            blackTimerView
                        }
                    }

                    boardView.padding(.vertical)

                    HStack {
                        undoButtonView

                        Spacer()

                        if gameVM.hasTimer {
                            whiteTimerView
                        }
                    }

                    Spacer()
                }
        }
    }
}
