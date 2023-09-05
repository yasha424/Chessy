//
//  GameViewModel.swift
//  Chessy
//
//  Created by Yasha Serhiienko on 30.07.2023.
//

import Combine
import CoreGraphics

class GameViewModel<ChessGame: Game>: ViewModelProtocol {

    internal var game: any Game
    private(set) var state: CurrentValueSubject<GameState, Never>
    internal var canPromotePawnAtPosition: Position?
    internal var fen: CurrentValueSubject<String, Never>

    private(set) var whiteCapturedPieces: CurrentValueSubject<[PieceType: Int], Never> = .init([:])
    private(set) var blackCapturedPieces: CurrentValueSubject<[PieceType: Int], Never> = .init([:])
    private(set) var value: CurrentValueSubject<Int, Never>

    internal var selectedPosition: CurrentValueSubject<Position?, Never> = .init(nil)
    internal var allowedMoves: CurrentValueSubject<[Position], Never> = .init([])
    internal var draggedTo: CurrentValueSubject<Position?, Never> = .init(nil)
    internal var lastMove: CurrentValueSubject<Move?, Never>
    internal var undidMove: CurrentValueSubject<Move?, Never> = .init(nil)
    internal var animatedMoves = [Move]()

    internal var turn: CurrentValueSubject<PieceColor, Never>
    internal var kingInCheckForColor: CurrentValueSubject<PieceColor?, Never>

    internal var hasTimer: Bool
    internal var whiteTime: CurrentValueSubject<Int?, Never>
    internal var blackTime: CurrentValueSubject<Int?, Never>
    private(set) var didUpdateGame: CurrentValueSubject<Bool, Never> = .init(false)

    init(game: ChessGame) {
        self.game = game
        self.hasTimer = game.timer != nil
        self.state = .init(game.state)
        self.turn = .init(game.turn)
        self.fen = .init(game.fen)
        self.whiteTime = .init(game.whiteTime)
        self.blackTime = .init(game.blackTime)
        self.canPromotePawnAtPosition = game.canPromotePawnAtPosition
        self.value = .init(game.value)
        self.kingInCheckForColor = .init(self.game.isKingInCheck(
            forColor: self.turn.value) ? self.turn.value : nil)
        self.lastMove = .init(game.history.last)
        self.whiteCapturedPieces = .init(capturedPieces(for: .white))
        self.blackCapturedPieces = .init(capturedPieces(for: .black))
        self.game.delegate = self
    }

    func undoLastMove() {
        DispatchQueue.main.async {
            if let move = self.lastMove.value {
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
            self.undidMove.send(self.lastMove.value)
            self.updateStates()
            self.selectedPosition.send(nil)
            self.allowedMoves.send([])
        }
    }

    private func updateStates() {
//        DispatchQueue.main.async {
            self.state.send(self.game.state)
//        }
        self.turn.send(self.game.turn)
        let isInCheck = self.game.isKingInCheck(forColor: self.turn.value) ? self.turn.value : nil
        if isInCheck != nil {
            HapticFeedbackService.instance.impact(style: .light)
        }
        self.kingInCheckForColor.send(isInCheck)
        self.lastMove.send(self.game.history.last)
        self.canPromotePawnAtPosition = self.game.canPromotePawnAtPosition
        self.fen.send(self.game.fen)
        self.whiteCapturedPieces.send(capturedPieces(for: .white))
        self.blackCapturedPieces.send(capturedPieces(for: .black))
        self.value.send(self.game.value)
    }

    func updateGame(with newGame: any Game) {
        DispatchQueue.main.async {
            self.game.delegate = nil
            if let newGame = newGame as? ChessGame {
                self.game = newGame
            }
            self.game.delegate = self
            self.whiteTime.send(self.game.whiteTime)
            self.blackTime.send(self.game.blackTime)
            self.selectedPosition.send(nil)
            self.allowedMoves.send([])
            self.animatedMoves = []
            self.updateStates()

            if let move = self.lastMove.value {
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
            self.didUpdateGame.send(true)
        }
    }

    func movePiece(fromPosition from: Position, toPosition to: Position, isAnimated: Bool = false) {
        self.game.movePiece(fromPosition: from, toPosition: to)

        self.lastMove.send(self.game.history.last)
        guard let move = self.lastMove.value,
              move.from == from, move.to == to else { return }
        self.updateStates()
        if isAnimated {
            self.animatedMoves = [move]
        } else {
            self.animatedMoves = []
        }
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
        let capture = self.lastMove.value?.capturedPiece != nil
        DispatchQueue.global(qos: .background).async {
            AudioPlayerService.instance.playSound(capture: capture)
        }
    }

    func promotePawn(to type: PieceType) {
        DispatchQueue.main.async {
            self.game.promotePawn(to: type)
            self.updateStates()
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

    func deselectPosition() {
        DispatchQueue.main.async {
            self.selectedPosition.send(nil)
            self.allowedMoves.send([])
            self.draggedTo.send(nil)
        }
    }

    func computeDraggedPosition(location: CGPoint, size: CGSize) {
        let deltaX = Int(((location.y - size.height / 2) / size.height).rounded())
        let deltaY = Int(((location.x - size.width / 2) / size.width).rounded())

        if let position = self.selectedPosition.value {
            let draggedPositionX = position.x - deltaX
            let draggedPositionY = position.y + deltaY

            guard draggedPositionX >= 0, draggedPositionX < 8,
                  draggedPositionY >= 0, draggedPositionY < 8 else {
                if self.draggedTo.value != nil {
                    DispatchQueue.main.async {
                        self.draggedTo.send(nil)
                    }
                }
                return
            }

            let to = Position(rawValue: (position.x - deltaX) * 8 + position.y + deltaY)
            if self.draggedTo.value != to {
                DispatchQueue.main.async {
                    self.draggedTo.send(to)
                }
            }
        } else {
            if self.draggedTo.value != nil {
                DispatchQueue.main.async {
                    self.draggedTo.send(nil)
                }
            }
        }
    }

    func endedGesture() {
        DispatchQueue.main.async {
            self.draggedTo.send(nil)
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
            if whiteTime.value != seconds {
                whiteTime.send(seconds)
            }
        case .black:
            if blackTime.value != seconds {
                blackTime.send(seconds)
            }
        }
    }

}
