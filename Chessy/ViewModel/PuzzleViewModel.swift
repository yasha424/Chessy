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
    private(set) var solved: CurrentValueSubject<Bool, Never> = .init(false)
    private var playedFirstMove: Bool = false
    private var isCreatingPuzzle: Bool = false

    init(puzzle: Puzzle, creating: Bool = false) {
        self.puzzle = puzzle
        self.moves = self.puzzle.moves
        let game = PuzzleGame(with: puzzle)
        self.playerColor = game.turn.opposite
        super.init(game: game)
        self.hasTimer = false
        isCreatingPuzzle = creating
    }

    func firstMove() {
        if self.turn.value != playerColor && !playedFirstMove {
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
        guard self.allowedMoves.value.contains(to) else { return }
        super.movePiece(fromPosition: from, toPosition: to, isAnimated: isAnimated)
        if isCreatingPuzzle {
            return
        }

        if self.turn.value != self.playerColor {
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
            solved.send(true)
        }
    }

    override func selectPosition(_ position: Position) {
        if self.selectedPosition.value == position {
            DispatchQueue.main.async {
                self.selectedPosition.send(nil)
                self.allowedMoves.send([])
            }
        } else {
            if let selectedPosition = self.selectedPosition.value {
                if canSelectPiece(atPosition: position) {
                    DispatchQueue.main.async {
                        self.selectedPosition.send(position)
                        self.allowedMoves.send(self.game.allMoves(fromPosition: position))
                    }
                } else {
                    DispatchQueue.main.async {
                        self.movePiece(
                            fromPosition: selectedPosition,
                            toPosition: position,
                            isAnimated: true
                        )
                        self.selectedPosition.send(nil)
                        self.allowedMoves.send([])
                    }
                }
            } else {
                if canSelectPiece(atPosition: position) {
                    DispatchQueue.main.async {
                        self.selectedPosition.send(position)
                        self.allowedMoves.send(self.game.allMoves(fromPosition: position))
                    }
                }
            }
        }
    }

    func skipMove() {
        if turn.value == playerColor {
            if let move = moves.first {
                allowedMoves.send([move.to])
                movePiece(fromPosition: move.from, toPosition: move.to)
                allowedMoves.send([])
            }
        }
    }
    
    func addPiece(_ piece: Piece, at position: Position) {
        self.game.board.addPieceForcing(piece, atPosition: position)
    }
    
    func removePiece(at position: Position) {
        self.game.board.removePiece(atPosition: position)
    }
    
    func setTurnColor(_ color: PieceColor) {
        self.game.turn = color
    }
    
    // return an error message or nil if position is valid
    func checkPosition() -> String? {
        let whiteKings = self.game.board.getCountOfKings(for: .white)
        let blackKings = self.game.board.getCountOfKings(for: .black)
        
        if whiteKings != 1 || blackKings != 1 {
            return "There must be one black and one white king on the board"
        }

        var whiteState: GameState = .inProgress
        var blackState: GameState = .inProgress
        if self.game.turn == .white {
            whiteState = self.game.getState()
            self.game.turn = .black
            blackState = self.game.getState()
            self.game.turn = .white
        } else {
            blackState = self.game.getState()
            self.game.turn = .white
            whiteState = self.game.getState()
            self.game.turn = .black
        }

        if whiteState == .checkmate(color: .white) || blackState == .checkmate(color: .black) {
            return "There is checkmate in this position. Try to make playable position"
        } else if whiteState == .stalemate(color: .white) || blackState == .stalemate(color: .black) {
            return "There is stalemate in this position. Try to make playable position"
        }
        
        return nil
    }
    
    func savePuzzle(_ email: String?) async {
        let history = self.game.history
        for _ in self.game.history {
            self.game.undoLastMove()
        }
        if let email = email {
            await PuzzleDataSource.instance.addPuzzle(
                Puzzle(id: self.puzzle.id, fen: self.game.fen, moves: history, rating: self.puzzle.rating),
                email: email
            )
        }
    }
    
    func setPuzzleRating(_ rating: Int) {
        if isCreatingPuzzle {
            self.puzzle.rating = rating
        }
    }
}
