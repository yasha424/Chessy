//
//  BoardView.swift
//  Chessy
//
//  Created by Yasha Serhiienko on 09.07.2023.
//

import SwiftUI

struct GameView<ChessGame>: View where ChessGame: Game {
    @ObservedObject var game: ChessGame
    private var boardView: BoardView<ChessGame>
    @Environment(\.verticalSizeClass) var sizeClass

    init(game: ChessGame) {
        self.game = game
        self.boardView = BoardView(game: game)
    }

    var body: some View {
        if sizeClass == .regular {
            VStack {
                HStack {
                    switch game.state {
                    case .checkmate(let color):
                        Text((color == .black ? "White" : "Black") + " has won by checkmate!")
                            .padding([.trailing, .leading])
                    case .stalemate:
                        Text("Stalemate!")
                            .padding([.trailing, .leading])
                    default:
                        EmptyView()
                    }
                }
                .aspectRatio(contentMode: .fill)
                .frame(height: 40)
                .glassView()
                .animation(.easeInOut, value: game.state)

                Spacer()

                if game.timer != nil {
                    HStack {
                        Spacer()
                        TimerView(game: game, color: .black)
                            .padding([.top, .trailing])
                    }
                }

                boardView

                HStack {
                    UndoButtonView(game: game)
                        .padding([.bottom, .leading])
                    Spacer()
                    if game.timer != nil {
                        TimerView(game: game, color: .white)
                            .padding([.bottom, .trailing])
                    }
                }

                Spacer()

            }
        } else {
            ZStack {
                HStack {
                    VStack {
                        Spacer()

                        UndoButtonView(game: game)
                            .padding(.bottom)
                    }

                    boardView

                    if game.timer != nil {
                        VStack {
                            TimerView(game: game, color: .black)
                                .padding(.top)
                            Spacer()
                            TimerView(game: game, color: .white)
                                .padding(.bottom)
                        }
                    }
                }

                VStack {
                    HStack {
                        switch game.state {
                        case .checkmate(let color):
                            Text((color == .black ? "White" : "Black") + " has won by checkmate!")
                                .padding([.trailing, .leading])
                        case .stalemate:
                            Text("Stalemate!")
                                .padding([.trailing, .leading])
                        default:
                            EmptyView()
                        }
                    }
                    .transition(.move(edge: .top))
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 40)
                    .glassView()
                    .animation(.easeInOut, value: game.state)

                    Spacer()
                }
            }
        }
    }

    mutating func updateGame(with newGame: ChessGame) {
        game = newGame
        boardView.updateGame(with: newGame)
    }

    func undoLastMove() {
        game.undoLastMove()
    }

}
