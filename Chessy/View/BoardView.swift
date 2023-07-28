//
//  BoardView.swift
//  Chessy
//
//  Created by Yasha Serhiienko on 24.07.2023.
//

import SwiftUI

struct BoardView<ChessGame>: View where ChessGame: Game {
    @ObservedObject var game: ChessGame
    @State private var selectedPosition: Position?
    @State private var allowedMoves = [Position]()
    @State private var selectedRow: Int?
    @State private var draggedTo: Position?
    @Environment(\.horizontalSizeClass) var sizeClass

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                ForEach(0..<8) { i in
                    HStack(spacing: 0) {
                        ForEach(0..<8) { j in
                            let position = Position(rawValue: (7 - i) * 8 + j)!

                            SquareView(
                                game: game,
                                selectedPosition: $selectedPosition,
                                allowedMoves: $allowedMoves,
                                selectedRow: $selectedRow,
                                draggedTo: $draggedTo,
                                position: position
                            )
                            .onTapGesture {
                                Thread {
                                    tappedAtPosition(position)
                                }.start()
                            }
                            .zIndex(selectedPosition == position ? 1 : 0)
                        }
                    }
                    .zIndex(selectedRow == i ? 1 : 0)
                }
            }

            if game.canPromotePawnAtPosition != nil {
                Color.black
                    .opacity(0.3)

                VStack {
                    Spacer()

                    HStack {
                        let pieceTypes: [PieceType] = [.queen, .rook, .bishop, .knight]

                        ForEach(pieceTypes) { type in
                            Button {
                                game.promotePawn(to: type)
                            } label: {
                                if let colorName = ImageNames.color[game.turn],
                                   let typeName = ImageNames.type[type] {
                                    let rotationDegrees = sizeClass == .compact ||
                                                          game.turn == .white ? 0.0 : 180.0
                                    Image(colorName + typeName)
                                        .resizable()
                                        .aspectRatio(1, contentMode: .fit)
                                        .padding()
                                        .rotationEffect(Angle(
                                            degrees: rotationDegrees
                                        ))
                                }
                            }
                            .glassView()
                            .frame(maxWidth: 80, maxHeight: 80)
                            .padding()
                        }
                    }

                    Spacer()
                }
                .ignoresSafeArea(.all)
            }
        }
        .aspectRatio(1, contentMode: .fit)
        .glassView()
        .padding()
    }

    mutating func updateGame(with newGame: ChessGame) {
        self.game = newGame
        selectedPosition = nil
        allowedMoves = []
        selectedRow = nil
        draggedTo = nil
    }

    private func tappedAtPosition(_ position: Position) {
        if let selectedPosition = selectedPosition {
            if selectedPosition == position {
                self.selectedPosition = nil
                self.selectedRow = nil
            } else if game.canSelectPiece(atPosition: position) {
                self.selectedPosition = position
                self.selectedRow = 7 - position.rawValue / 8
            } else {
                DispatchQueue.main.async {
                    game.movePiece(
                        fromPosition: selectedPosition,
                        toPosition: position
                    )
                }
                self.selectedPosition = nil
                self.selectedRow = nil
            }
        } else {
            if game.canSelectPiece(atPosition: position) {
                selectedPosition = position
                selectedRow = 7 - position.rawValue / 8
            } else {
                selectedPosition = nil
                selectedRow = nil
            }
        }

        if selectedPosition != nil {
            allowedMoves = game.allMoves(fromPosition: position)
        } else {
            allowedMoves = []
        }
    }

}
