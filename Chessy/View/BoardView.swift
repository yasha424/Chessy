//
//  BoardView.swift
//  Chessy
//
//  Created by Yasha Serhiienko on 09.07.2023.
//

import SwiftUI

struct BoardView<ChessGame>: View where ChessGame: Game {
    
    @ObservedObject var game: ChessGame
    @State private var selectedPosition: Position? = nil
    @State private var allowedMoves = [Position]()
    @State private var selectedRow: Int? = nil
    @State private var draggedTo: Position? = nil
    
    var body: some View {
        VStack(spacing: 0) {
            ForEach(0..<8) { i in
                HStack(spacing: 0) {
                    ForEach(0..<8) { j in
                        let position = Position(rawValue: (7 - i) * 8 + j)!
                        CellView(
                            game: game,
                            selectedPosition: $selectedPosition,
                            allowedMoves: $allowedMoves,
                            selectedRow: $selectedRow,
                            draggedTo: $draggedTo,
                            i: i,
                            j: j
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
        .aspectRatio(1, contentMode: .fit)
        .border(Color.black)
    }
    
    private func tappedAtPosition(_ position: Position) {
        if let selectedPosition = selectedPosition {
            if selectedPosition == position {
                self.selectedPosition = nil
                self.selectedRow = nil
            } else if game.canSelectPiece(atPosition: position) {
                self.selectedPosition = position
                self.selectedRow = position.rawValue / 8
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
                selectedRow = position.rawValue / 8
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
