//
//  BoardView.swift
//  Chessy
//
//  Created by Yasha Serhiienko on 24.07.2023.
//

import SwiftUI

struct BoardView<ChessGame: Game>: View {

    @EnvironmentObject var gameVM: GameViewModel<ChessGame>

    @AppStorage("shouldRotate") var shouldRotate: Bool = false

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                ForEach(0..<8) { i in
                    HStack(spacing: 0) {
                        ForEach(0..<8) { j in
                            let position = Position(rawValue: (7 - i) * 8 + j)!

                            SquareView<ChessGame>(
                                piece: gameVM.getPiece(atPosition: position),
                                position: position
                            )
                            .zIndex(gameVM.selectedPosition == position ? 2 :
                                        (gameVM.lastMove?.to == position ? 1 : 0))
                        }
                    }
                    .zIndex(gameVM.selectedPosition?.x == 7 - i ? 2 :
                                gameVM.lastMove?.to.x == 7 - i ? 1 : 0)
                }
            }
            .padding(10)

            if let position = gameVM.canPromotePawnAtPosition {
                Color.black.opacity(0.3)

                VStack {
                    Spacer()

                    HStack {
                        let pieceTypes: [PieceType] = [.queen, .rook, .bishop, .knight]

                        Spacer()

                        ForEach(pieceTypes) { type in
                            Button {
                                gameVM.promotePawn(to: type)
                            } label: {
                                if let piece = gameVM.getPiece(atPosition: position),
                                   let colorName = ImageNames.color[piece.color],
                                   let typeName = ImageNames.type[type] {
                                    let rotationDegrees = (gameVM.turn == .black &&
                                                           shouldRotate) ? 180.0 : 0.0
                                    Image(colorName + typeName)
                                        .resizable()
                                        .padding(8)
                                        .rotationEffect(Angle(
                                            degrees: rotationDegrees
                                        ))
                                }
                            }
                            .aspectRatio(1, contentMode: .fit)
                            .frame(minWidth: 20, maxWidth: 80, minHeight: 20, maxHeight: 80)
                            .glassView()

                            Spacer()
                        }
                    }

                    Spacer()
                }
            }
        }
        .aspectRatio(1, contentMode: .fit)
        .glassView()
    }

}
