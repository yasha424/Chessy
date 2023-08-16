//
//  BoardView.swift
//  Chessy
//
//  Created by Yasha Serhiienko on 09.07.2023.
//

import SwiftUI

struct GameView<ViewModel: ViewModelProtocol>: View {

    @EnvironmentObject var gameVM: ViewModel

    @State var boardView: BoardView<ViewModel>!
    let blackTimerView = TimerView<ClassicGame>(color: .black)
    let whiteTimerView = TimerView<ClassicGame>(color: .white)
    let undoButtonView = UndoButtonView<ClassicGame>()

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
                if gameVM.hasTimer {
                    HStack {
                        Spacer()

                        blackTimerView
                    }
                }

                boardView.padding(.vertical, 8)

                HStack {
                    undoButtonView

                    Spacer()

                    if gameVM.hasTimer {
                        whiteTimerView
                    }
                }
            }
        }
        .onAppear {
            boardView = BoardView<ViewModel>(vm: gameVM)
        }
    }
}
