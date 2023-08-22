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

    @State var isWhiteCapturedPiecesShown: Bool = true
    @State var isBlackCapturedPiecesShown: Bool = true

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
                    HStack(spacing: 0) {
                        if isWhiteCapturedPiecesShown {
                            let capturedPieces = gameVM.whiteCapturedPiece.sorted { first, second in
                                first.key.value > second.key.value
                            }
                            ForEach(capturedPieces, id: \.key) { pieceType, num in
                                if num > 0 {
                                    ZStack {
                                        ForEach(0..<num, id: \.self) { i in
                                            Image(ImageNames.color[.white]! +
                                                  ImageNames.type[pieceType]!)
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .offset(x: (CGFloat(i) - CGFloat(num) / 2) * 10 + 5)
                                            .transition(.scale)
                                        }
                                    }
                                    .frame(width: 26 + CGFloat(num - 1) * 10)
                                }
                            }
                            if gameVM.value < 0 {
                                let valueString = "+\(-gameVM.value)"
                                Text(valueString)
                                    .font(.body.monospaced())
                                    .opacity(0.5)
                                    .frame(width: 40)
                                    .transition(.scale)
                            }
                        }
                    }
                    .padding(8)
                    .frame(height: 40)
                    .glassView()
                    .onTapGesture {
                        withAnimation(.spring(response: 0.5)) {
                            isWhiteCapturedPiecesShown.toggle()
                        }
                    }
                    .animation(.spring(response: 0.5), value: gameVM.whiteCapturedPiece)
                    .animation(.spring(response: 0.5), value: gameVM.value)

                    Spacer()

                    if gameVM.hasTimer {
                        blackTimerView
                    }
                }

                boardView.padding(.vertical, 8)

                HStack {
                    HStack(spacing: 0) {
                        if isBlackCapturedPiecesShown {
                            let capturedPieces = gameVM.blackCapturedPiece.sorted { first, second in
                                first.key.value > second.key.value
                            }
                            ForEach(capturedPieces, id: \.key) { pieceType, num in
                                if num > 0 {
                                    ZStack {
                                        ForEach(0..<num, id: \.self) { i in
                                            Image(ImageNames.color[.black]! +
                                                  ImageNames.type[pieceType]!)
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .offset(x: (CGFloat(i) - CGFloat(num) / 2) * 10 + 5)
                                            .transition(.scale)
                                        }
                                    }
                                    .frame(width: 26 + CGFloat(num - 1) * 10)
                                }
                            }
                            if gameVM.value > 0 {
                                Text("+\(gameVM.value)")
                                    .font(.body.monospaced())
                                    .opacity(0.5)
                                    .frame(width: 40)
                                    .transition(.scale)
                            }
                        }
                    }
                    .padding(8)
                    .frame(height: 40)
                    .glassView()
                    .onTapGesture {
                        withAnimation(.spring(response: 0.5)) {
                            isBlackCapturedPiecesShown.toggle()
                        }
                    }
                    .animation(.spring(response: 0.5), value: gameVM.blackCapturedPiece)
                    .animation(.spring(response: 0.5), value: gameVM.value)

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
            boardView = BoardView<ViewModel>(vm: gameVM)
        }
    }
}
