//
//  BoardView.swift
//  Chessy
//
//  Created by Yasha Serhiienko on 24.07.2023.
//

import SwiftUI

struct BoardView<ChessGame: Game>: View {
    @ObservedObject var gameVM: GameViewModel<ChessGame>
    @Environment(\.horizontalSizeClass) var sizeClass

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                ForEach(0..<8) { i in
                    HStack(spacing: 0) {
                        ForEach(0..<8) { j in
                            let position = Position(rawValue: (7 - i) * 8 + j)!

                            SquareView(gameVM: gameVM, position: position)
                                .onTapGesture {
                                    Thread {
                                        tappedAtPosition(position)
                                    }.start()
                                }
                                .zIndex(gameVM.selectedPosition == position ? 2 : 0)
                        }
                    }
                    .zIndex(gameVM.selectedRow == i ? 1 : 0)
                }
            }

            if let position = gameVM.canPromotePawnAtPosition {
                Color.black.opacity(0.3)

                VStack {
                    Spacer()

                    HStack {
                        let pieceTypes: [PieceType] = [.queen, .rook, .bishop, .knight]

                        ForEach(pieceTypes) { type in
                            Button {
                                gameVM.promotePawn(to: type)
                            } label: {
                                if let piece = gameVM.getPiece(atPosition: position),
                                   let colorName = ImageNames.color[piece.color],
                                   let typeName = ImageNames.type[type] {
                                   let rotationDegrees = sizeClass == .compact ||
                                        gameVM.turn == .white ? 0.0 : 180.0
                                    Image(colorName + typeName)
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .padding()
                                        .rotationEffect(Angle(
                                            degrees: rotationDegrees
                                        ))
                                }
                            }
                            .aspectRatio(1, contentMode: .fit)
                            .frame(maxWidth: 80, maxHeight: 80)
                            .glassView()
                            .padding()
                        }
                    }

                    Spacer()
                }
            }
        }
        .aspectRatio(1, contentMode: .fit)
        .glassView()
    }

    private func tappedAtPosition(_ position: Position) {
        if let selectedPosition = gameVM.selectedPosition {
            if selectedPosition == position {
                gameVM.deselectPosition()
                gameVM.selectedRow = nil
            } else if gameVM.canSelectPiece(atPosition: position) {
                gameVM.selectPosition(position)
                gameVM.selectedRow = 7 - position.rawValue / 8
            } else {
                gameVM.movePiece(
                    fromPosition: selectedPosition,
                    toPosition: position,
                    isAnimated: true
                )
                gameVM.deselectPosition()
                gameVM.selectedRow = nil
            }
        } else {
            if gameVM.canSelectPiece(atPosition: position) {
                gameVM.selectPosition(position)
                gameVM.selectedRow = 7 - position.rawValue / 8
            } else {
                gameVM.deselectPosition()
                gameVM.selectedRow = nil
            }
        }
    }

}
