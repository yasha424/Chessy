//
//  PuzzleViewModel.swift
//  Chessy
//
//  Created by Yasha Serhiienko on 01.08.2023.
//

import Combine
import CoreGraphics
import Foundation

class PuzzleViewModel: GameViewModel<PuzzleGame> {

    private(set) var puzzle: Puzzle
    private var moves = [Move]()
    private var playerColor: PieceColor

    init(puzzle: Puzzle) {
        self.puzzle = puzzle
        self.moves = self.puzzle.moves
        let game = PuzzleGame(with: puzzle)
        self.playerColor = game.turn.opposite
        super.init(game: game)
        self.hasTimer = false

//        if let firstMove = self.puzzle.moves.first {
////            print(self.turn)
////            self.allowedMoves = [firstMove.to]
//            super.movePiece(
//                fromPosition: firstMove.from,
//                toPosition: firstMove.to,
//                isAnimated: true
//            )
////            self.allowedMoves = []
//            self.moves.removeFirst()
//        }
    }

    func firstMove() {
        if self.turn != playerColor && !self.moves.isEmpty {
            if let firstMove = self.puzzle.moves.first {
                super.movePiece(
                    fromPosition: firstMove.from,
                    toPosition: firstMove.to,
                    isAnimated: true
                )
                self.moves.removeFirst()
            }
        }
    }

    override func movePiece(fromPosition from: Position,
                            toPosition to: Position,
                            isAnimated: Bool = false) {
        super.movePiece(fromPosition: from, toPosition: to, isAnimated: isAnimated)
//        self.turn = self.game.turn
//        print(self.turn)

        if self.turn == self.playerColor {
            if from == self.moves.first?.from, to == self.moves.first?.to {
                self.moves.removeFirst()
                if let puzzleMove = self.moves.first {
//                    self.allowedMoves = [puzzleMove.to]
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        super.movePiece(
                            fromPosition: puzzleMove.from,
                            toPosition: puzzleMove.to,
                            isAnimated: isAnimated
                        )
                    }
//                    self.allowedMoves = []
                    self.moves.removeFirst()
                }
            } else {
                self.undoLastMove()
            }
        }
    }

    override func selectPosition(_ position: Position) {
        if self.selectedPosition == position {
            DispatchQueue.main.async {
                self.selectedPosition = nil
                self.allowedMoves = []
            }
        } else {
            if let selectedPosition = self.selectedPosition {
                if canSelectPiece(atPosition: position) {
                    DispatchQueue.main.async {
                        self.selectedPosition = position
                        self.allowedMoves = self.game.allMoves(fromPosition: position)
                    }
                } else {
                    DispatchQueue.main.async {
                        self.movePiece(
                            fromPosition: selectedPosition,
                            toPosition: position,
                            isAnimated: true
                        )
//                    DispatchQueue.main.async {
                        self.selectedPosition = nil
                        self.allowedMoves = []
                    }
                }
            } else {
                if canSelectPiece(atPosition: position) {
                    DispatchQueue.main.async {
                        self.selectedPosition = position
                        self.allowedMoves = self.game.allMoves(fromPosition: position)
                    }
                }
            }
        }
    }

}
