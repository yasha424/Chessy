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

    var body: some View {
        if sizeClass == .regular {
            VStack {
                HStack {
                    switch gameVM.state {
                    case .checkmate(let color):
                        HStack {
                            Text((color == .black ? "White" : "Black") + " has won by checkmate!")
                                .padding([.leading, .trailing])
                                .frame(height: 40)
                                .glassView()
                                .padding()
                        }
                            .transition(.move(edge: .top))
                    case .stalemate:
                        HStack {
                            Text("Stalemate!")
                                .padding([.leading, .trailing])
                                .frame(height: 40)
                                .glassView()
                                .padding()
                        }
                        .transition(.move(edge: .top))
                    default:
                        EmptyView()
                    }
                }
                .aspectRatio(contentMode: .fill)
                .frame(height: 40)
                .animation(.spring(), value: gameVM.state)

                Spacer()

                if gameVM.hasTimer {
                    HStack {
                        Spacer()
                        TimerView(gameVM: gameVM, color: .black)
                    }
                }

                BoardView(gameVM: gameVM)
                    .padding([.top, .bottom])

                HStack {
                    UndoButtonView(gameVM: gameVM)

                    Spacer()

                    if gameVM.hasTimer {
                        TimerView(gameVM: gameVM, color: .white)
                    }
                }

                Spacer()

            }
        } else {
            ZStack {
                HStack {
                    VStack {
                        Spacer()

                        UndoButtonView(gameVM: gameVM)
                            .padding(.bottom)
                    }

                    BoardView(gameVM: gameVM)

                    if gameVM.hasTimer {
                        VStack {
                            TimerView(gameVM: gameVM, color: .black)
                                .padding(.top)
                            Spacer()
                            TimerView(gameVM: gameVM, color: .white)
                                .padding(.bottom)
                        }
                    }
                }

                VStack {
                    HStack {
                        switch gameVM.state {
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
                    .animation(.spring(response: 0.3, dampingFraction: 1), value: gameVM.state)

                    Spacer()
                }
            }
        }
    }
}
