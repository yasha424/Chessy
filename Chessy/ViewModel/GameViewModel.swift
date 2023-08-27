//
//  GameViewModel.swift
//  Chessy
//
//  Created by Yasha Serhiienko on 30.07.2023.
//

import Combine
import Dispatch
import CoreGraphics
import AVFoundation

class GameViewModel<ChessGame: Game>: ViewModelProtocol {

    internal var game: any Game
    @Published private(set) var state: GameState
    internal var canPromotePawnAtPosition: Position?
    internal var fen: String

    private(set) var whiteCapturedPieces = [PieceType: Int]()
    private(set) var blackCapturedPieces = [PieceType: Int]()
    private(set) var value = 0

    internal var selectedPosition: CurrentValueSubject<Position?, Never> = .init(nil)
    internal var allowedMoves: CurrentValueSubject<[Position], Never> = .init([])
    internal var draggedTo: CurrentValueSubject<Position?, Never> = .init(nil)
    internal var lastMove: CurrentValueSubject<Move?, Never> = .init(nil)
    internal var animatedMoves = [Move]()

    internal var turn: PieceColor
    internal var kingInCheckForColor: PieceColor?

    internal var hasTimer: Bool
    internal var whiteTime: CurrentValueSubject<Int?, Never>
    internal var blackTime: CurrentValueSubject<Int?, Never>
    let audioPlayerService = AudioPlayerService(
        moveSoundUrl: Bundle.main.url(forResource: "move", withExtension: "mp3"),
        captureSoundUrl: Bundle.main.url(forResource: "capture", withExtension: "mp3")
    )

    init(game: ChessGame) {
        self.game = game
        self.hasTimer = game.timer != nil
        self.state = game.state
        self.turn = game.turn
        self.fen = game.fen
        self.whiteTime = .init(game.whiteTime)
        self.blackTime = .init(game.blackTime)
        self.canPromotePawnAtPosition = game.canPromotePawnAtPosition
        self.whiteCapturedPieces = capturedPieces(for: .white)
        self.blackCapturedPieces = capturedPieces(for: .black)
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
            self.updateStates()
            self.selectedPosition.send(nil)
            self.allowedMoves.send([])
        }
    }

    private func updateStates() {
        DispatchQueue.main.async {
            self.state = self.game.state
        }
        self.turn = self.game.turn
        self.kingInCheckForColor = self.game.isKingInCheck(
            forColor: self.turn) ? self.turn : nil
        self.lastMove.send(self.game.history.last)
        self.canPromotePawnAtPosition = self.game.canPromotePawnAtPosition
        self.fen = self.game.fen
        self.whiteCapturedPieces = capturedPieces(for: .white)
        self.blackCapturedPieces = capturedPieces(for: .black)
        self.value = self.game.value
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
        DispatchQueue.global(qos: .background).async {
            self.audioPlayerService.playSound(capture: self.lastMove.value?.capturedPiece != nil)
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
