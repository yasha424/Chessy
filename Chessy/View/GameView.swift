//
//  BoardView.swift
//  Chessy
//
//  Created by Yasha Serhiienko on 09.07.2023.
//

import SwiftUI

struct GameView<ChessGame: Game>: View {

    @ObservedObject var gameVM: GameViewModel<ChessGame>
    @Environment(\.verticalSizeClass) var sizeClass

    private let boardView: BoardView<ChessGame>!
    private let blackTimerView: TimerView<ChessGame>!
    private let whiteTimerView: TimerView<ChessGame>!
    private let undoButtonView: UndoButtonView<ChessGame>!

    @Environment(\.shouldRotate) var shouldRotate: Bool

    init(gameVM: GameViewModel<ChessGame>) {
        self.gameVM = gameVM

        self.boardView = BoardView(gameVM: gameVM)
        self.blackTimerView = TimerView(gameVM: gameVM, color: .black)
        self.whiteTimerView = TimerView(gameVM: gameVM, color: .white)
        self.undoButtonView = UndoButtonView(gameVM: gameVM)
    }

    var body: some View {
        ZStack {
            VStack {
                switch gameVM.state {
                case .checkmate(let color):
                    Text((color == .black ? "White" : "Black") + " won by checkmate!")
                        .padding([.leading, .trailing])
                        .frame(height: 40)
                        .glassView()
                        .padding(.top, 40)
                        .transition(.move(edge: .top))
                case .stalemate:
                    Text("Stalemate!")
                        .padding([.leading, .trailing])
                        .frame(height: 40)
                        .glassView()
                        .padding(.top, 40)
                        .transition(.move(edge: .top))
                default:
                    EmptyView()
                }

                Spacer()
            }
            .zIndex(3.0)
            .animation(.spring(response: 0.3), value: gameVM.state)

            if sizeClass == .regular {
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
                .padding(.top)
            } else {
                HStack {
                    VStack {
                        Spacer()

                        undoButtonView
                    }

                    boardView.padding(.horizontal)

                    if gameVM.hasTimer {
                        VStack {
                            blackTimerView

                            Spacer()

                            whiteTimerView
                        }
                    }
                }
                .padding(.top)
            }
        }
    }
}
