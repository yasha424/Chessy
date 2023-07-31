//
//  GameViewModel.swift
//  Chessy
//
//  Created by Yasha Serhiienko on 30.07.2023.
//

import Combine
import Dispatch

class GameViewModel<ChessGame: Game>: ObservableObject {

    private var game: ChessGame
    @Published private(set) var state: GameState
    private(set) var canPromotePawnAtPosition: Position?

    private(set) var selectedPosition: Position?
    @Published private(set) var allowedMoves = [Position]()
    var selectedRow: Int?
    @Published var draggedTo: Position?
    private(set) var lastMove: Move?
    private(set) var animatedMove: Move?

    private(set) var turn: PieceColor

    private(set) var hasTimer: Bool
    @Published private(set) var whiteTime: Int?
    @Published private(set) var blackTime: Int?

    init(game: ChessGame) {
        self.game = game
        self.hasTimer = game.timer != nil
        self.state = game.state
        self.turn = game.turn
        self.game.delegate = self
        self.whiteTime = game.whiteTime
        self.blackTime = game.blackTime
        self.canPromotePawnAtPosition = game.canPromotePawnAtPosition
    }

    func addTime(for color: PieceColor) {
        DispatchQueue.main.async {
            if self.hasTimer {
                self.game.addTime(for: color)
            }
        }
    }

    func undoLastMove() {
        DispatchQueue.main.async {
            if let move = self.lastMove {
                self.animatedMove = Move(from: move.to, to: move.from, piece: move.piece)
            }
            self.game.undoLastMove()
            self.state = self.game.state
            self.lastMove = nil
            self.turn = self.game.turn
            self.lastMove = self.game.history.last
            self.canPromotePawnAtPosition = self.game.canPromotePawnAtPosition
        }
    }

    func updateGame(with newGame: ChessGame) {
        DispatchQueue.main.async {
            self.game.delegate = nil
            self.game = newGame
            self.state = self.game.state
            self.turn = self.game.turn
            self.game.delegate = self
            self.whiteTime = self.game.whiteTime
            self.blackTime = self.game.blackTime
            self.canPromotePawnAtPosition = self.game.canPromotePawnAtPosition
            self.lastMove = self.game.history.last
            if let move = self.lastMove {
                self.animatedMove = Move(from: move.to, to: move.from, piece: move.piece)
            }
            self.selectedRow = nil
            self.selectedPosition = nil
            self.allowedMoves = []
        }
    }

    func movePiece(fromPosition from: Position, toPosition to: Position, isAnimated: Bool = false) {
        DispatchQueue.main.async {
            self.game.movePiece(fromPosition: from, toPosition: to)
            self.state = self.game.state
            self.turn = self.game.turn
            self.lastMove = self.game.history.last
            self.canPromotePawnAtPosition = self.game.canPromotePawnAtPosition
            if isAnimated {
                self.animatedMove = self.lastMove
            } else {
                self.animatedMove = nil
            }
        }
    }

    func promotePawn(to type: PieceType) {
        DispatchQueue.main.async {
            self.game.promotePawn(to: type)
            self.turn = self.game.turn
            self.state = self.game.state
            self.lastMove = self.game.history.last
            self.canPromotePawnAtPosition = self.game.canPromotePawnAtPosition
            self.animatedMove = nil
        }
    }

    func canSelectPiece(atPosition position: Position) -> Bool {
        return game.canSelectPiece(atPosition: position)
    }

    func getPiece(atPosition position: Position) -> Piece? {
        return game.board[position]
    }

    func isKingInCheck(forColor color: PieceColor) -> Bool {
        return game.isKingInCheck(forColor: color)
    }

    func selectPosition(_ position: Position) {
        DispatchQueue.main.async {
            self.selectedPosition = position
            self.allowedMoves = self.game.allMoves(fromPosition: position)
        }
    }

    func deselectPosition() {
        DispatchQueue.main.async {
            self.selectedPosition = nil
            self.allowedMoves = []
        }
    }

}

extension GameViewModel: GameDelegate {

    func didUpdateTime(with time: Int, for color: PieceColor) {
        let seconds = time / 10
        switch color {
        case .white:
            if whiteTime != seconds {
                whiteTime = seconds
            }
        case .black:
            if blackTime != seconds {
                blackTime = seconds
            }
        }
    }

}
