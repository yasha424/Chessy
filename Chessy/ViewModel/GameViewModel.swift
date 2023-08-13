//
//  GameViewModel.swift
//  Chessy
//
//  Created by Yasha Serhiienko on 30.07.2023.
//

import Combine
import Dispatch
import CoreGraphics

class GameViewModel<ChessGame: Game>: ObservableObject {

    private var game: ChessGame
    @Published private(set) var state: GameState
    private(set) var canPromotePawnAtPosition: Position?
    private(set) var fen: String

    @Published private(set) var selectedPosition: Position?
    private(set) var allowedMoves = [Position]()
    @Published private(set) var draggedTo: Position?
    private(set) var lastMove: Move?
    private(set) var animatedMoves = [Move]()

    private(set) var turn: PieceColor
    private(set) var kingInCheckForColor: PieceColor?

    private(set) var hasTimer: Bool
    @Published private(set) var whiteTime: Int?
    @Published private(set) var blackTime: Int?

    init(game: ChessGame) {
        self.game = game
        self.hasTimer = game.timer != nil
        self.state = game.state
        self.turn = game.turn
        self.fen = game.fen
        self.game.delegate = self
        self.whiteTime = game.whiteTime
        self.blackTime = game.blackTime
        self.canPromotePawnAtPosition = game.canPromotePawnAtPosition
    }

    func undoLastMove() {
        DispatchQueue.main.async {
            if let move = self.lastMove {
                self.animatedMoves = [Move(from: move.to, to: move.from, piece: move.piece)]

                if let castling = move.castling {
                    let from = Position.fromCoordinates(
                        x: move.from.x,
                        y: castling == .kingSide ? 5 : 3
                    )
                    let to = Position.fromCoordinates(
                        x: move.to.x,
                        y: castling == .kingSide ? 7 : 0
                    )
                    guard let from = from, let to = to else { return }
                    self.animatedMoves.append(Move(from: from, to: to, piece: self.game.board[to]))
                }
            }
            self.game.undoLastMove()
            self.state = self.game.state
            self.lastMove = nil
            self.turn = self.game.turn
            self.kingInCheckForColor = self.game.isKingInCheck(
                forColor: self.turn) ? self.turn : nil
            self.lastMove = self.game.history.last
            self.canPromotePawnAtPosition = self.game.canPromotePawnAtPosition
            self.fen = self.game.fen
            self.selectedPosition = nil
            self.allowedMoves = []
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
            self.fen = self.game.fen
            self.selectedPosition = nil
            self.allowedMoves = []
            self.animatedMoves = []

            if let move = self.lastMove {
                self.animatedMoves = [Move(from: move.to, to: move.from, piece: move.piece)]

                if let castling = move.castling {
                    let from = Position.fromCoordinates(
                        x: move.from.x,
                        y: castling == .kingSide ? 7 : 0
                    )
                    let to = Position.fromCoordinates(
                        x: move.to.x,
                        y: castling == .kingSide ? 5 : 3
                    )
                    guard let from = from, let to = to else { return }
                    self.animatedMoves.append(Move(from: from, to: to, piece: self.game.board[to]))
                }
            }

        }
    }

    func movePiece(fromPosition from: Position, toPosition to: Position, isAnimated: Bool = false) {
        DispatchQueue.main.async {
            self.game.movePiece(fromPosition: from, toPosition: to)
            self.state = self.game.state
            self.turn = self.game.turn
            self.kingInCheckForColor = self.game.isKingInCheck(
                forColor: self.turn) ? self.turn : nil
            self.lastMove = self.game.history.last
            self.canPromotePawnAtPosition = self.game.canPromotePawnAtPosition
            self.fen = self.game.fen
            if isAnimated {
                if let move = self.lastMove {
                    self.animatedMoves = [move]

                    if let castling = move.castling {
                        let from = Position.fromCoordinates(
                            x: move.from.x,
                            y: castling == .kingSide ? 7 : 0
                        )
                        let to = Position.fromCoordinates(
                            x: move.to.x,
                            y: castling == .kingSide ? 5 : 3
                        )
                        guard let from = from, let to = to else { return }
                        self.animatedMoves.append(
                            Move(from: from, to: to, piece: self.game.board[to])
                        )
                    }
                }
            } else {
                self.animatedMoves = []
            }
        }
    }

    func promotePawn(to type: PieceType) {
        DispatchQueue.main.async {
            self.game.promotePawn(to: type)
            self.turn = self.game.turn
            self.state = self.game.state
            self.kingInCheckForColor = self.game.isKingInCheck(
                forColor: self.turn) ? self.turn : nil
            self.lastMove = self.game.history.last
            self.fen = self.game.fen
            self.canPromotePawnAtPosition = self.game.canPromotePawnAtPosition
            self.animatedMoves = []
        }
    }

    func canSelectPiece(atPosition position: Position) -> Bool {
        return game.canSelectPiece(atPosition: position)
    }

    func getPiece(atPosition position: Position) -> Piece? {
        return game.board[position]
    }

    func selectPosition(_ position: Position) {
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
                    movePiece(
                        fromPosition: selectedPosition,
                        toPosition: position,
                        isAnimated: true
                    )
                    DispatchQueue.main.async {
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

    func deselectPosition() {
        DispatchQueue.main.async {
            self.selectedPosition = nil
            self.allowedMoves = []
            self.draggedTo = nil
        }
    }

    func computeDraggedPosition(location: CGPoint, size: CGSize) {
        let deltaX = Int(((location.y - size.height / 2) / size.height).rounded())
        let deltaY = Int(((location.x - size.width / 2) / size.width).rounded())

        if let position = self.selectedPosition {
            let draggedPositionX = position.x - deltaX
            let draggedPositionY = position.y + deltaY

            guard draggedPositionX >= 0, draggedPositionX < 8,
                  draggedPositionY >= 0, draggedPositionY < 8 else {
                if self.draggedTo != nil {
                    DispatchQueue.main.async {
                        self.draggedTo = nil
                    }
                }
                return
            }

            let to = Position(rawValue: (position.x - deltaX) * 8 + position.y + deltaY)
            if self.draggedTo != to {
                DispatchQueue.main.async {
                    self.draggedTo = to
                }
            }
        } else {
            if self.draggedTo != nil {
                DispatchQueue.main.async {
                    self.draggedTo = nil
                }
            }
        }
    }

    func endedGesture() {
        DispatchQueue.main.async {
            self.draggedTo = nil
        }
    }
}

extension GameViewModel: GameDelegate {

    func setTime(seconds: Int, for color: PieceColor) {
        DispatchQueue.main.async {
            self.game.timer?.set(seconds: seconds, for: color)
        }
    }

    func addTime(for color: PieceColor) {
        DispatchQueue.main.async {
            if self.hasTimer {
                self.game.addTime(for: color)
            }
        }
    }

    func startTimer() {
        DispatchQueue.main.async {
            self.game.timer?.start()
        }
    }

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
