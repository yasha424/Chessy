//
//  BoardView.swift
//  Chessy
//
//  Created by Yasha Serhiienko on 09.07.2023.
//

import SwiftUI

struct GameView<ViewModel: ViewModelProtocol>: View {

    @EnvironmentObject private var gameVM: ViewModel

    @State private var boardView: BoardView<ViewModel>!
    private let blackTimerView = TimerView<ClassicGame>(color: .black)
    private let whiteTimerView = TimerView<ClassicGame>(color: .white)
    private let undoButtonView = UndoButtonView<ClassicGame>()
    private let whiteCapturedPiecesView = CapturedPiecesView<ViewModel>(color: .white)
    private let blackCapturedPiecesView = CapturedPiecesView<ViewModel>(color: .black)
    @AppStorage("shouldRotate") private var shouldRotate = false

    var body: some View {
        ZStack {
            VStack {
                switch gameVM.state {
                case .checkmate(let color):
                    if color == .white {
                        Text("Black won by checkmate!")
                            .padding([.leading, .trailing])
                            .frame(height: 40)
                            .glassView()
                            .transition(.move(edge: .top))
                    } else {
                        Text("White won by checkmate!")
                            .padding([.leading, .trailing])
                            .frame(height: 40)
                            .glassView()
                            .transition(.move(edge: .top))
                    }
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
                HStack {
                    whiteCapturedPiecesView

                    Spacer()

                    if gameVM.hasTimer {
                        blackTimerView
                    }
                }

                boardView.padding(.vertical, 8)

                HStack {
                    blackCapturedPiecesView

                    Spacer()

                    if gameVM.hasTimer {
                        whiteTimerView
                    }
                }
                HStack {
                    undoButtonView
                    Spacer()
                }
                .padding(.top, 8)
            }
        }
        .onAppear {
            boardView = BoardView<ViewModel>(vm: gameVM, shouldRotate: $shouldRotate)
        }
    }
}
