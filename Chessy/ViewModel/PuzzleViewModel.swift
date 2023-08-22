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
    private(set) var playerColor: PieceColor
    private(set) var solved: Bool = false
    private var playedFirstMove: Bool = false

    init(puzzle: Puzzle) {
        self.puzzle = puzzle
        self.moves = self.puzzle.moves
        let game = PuzzleGame(with: puzzle)
        self.playerColor = game.turn.opposite
        super.init(game: game)
        self.hasTimer = false

    }

    func firstMove() {
        if self.turn != playerColor && !self.moves.isEmpty && !playedFirstMove {
            if let firstMove = self.puzzle.moves.first {
                super.movePiece(
                    fromPosition: firstMove.from,
                    toPosition: firstMove.to,
                    isAnimated: true
                )
                self.moves.removeFirst()
                playedFirstMove = true
            }
        }
    }

    override func movePiece(fromPosition from: Position,
                            toPosition to: Position,
                            isAnimated: Bool = false) {
        guard self.allowedMoves.contains(to) else { return }
        super.movePiece(fromPosition: from, toPosition: to, isAnimated: isAnimated)

        if self.turn != self.playerColor {
            if from == self.moves.first?.from, to == self.moves.first?.to {
                self.moves.removeFirst()
                if let puzzleMove = self.moves.first {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        super.movePiece(
                            fromPosition: puzzleMove.from,
                            toPosition: puzzleMove.to,
                            isAnimated: true
                        )
                    }
                    self.moves.removeFirst()
                }
            } else {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    self.undoLastMove()
                }
            }
        }
        if self.moves.isEmpty {
            solved = true
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
