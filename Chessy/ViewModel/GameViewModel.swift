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
    private(set) var whiteCapturedPiece = [PieceType: Int]()
    private(set) var blackCapturedPiece = [PieceType: Int]()
    private(set) var value = 0

    @Published internal var selectedPosition: Position?
    internal var allowedMoves = [Position]()
    @Published internal var draggedTo: Position?
    internal var lastMove: Move?
    internal var animatedMoves = [Move]()

    internal var turn: PieceColor
    internal var kingInCheckForColor: PieceColor?

    internal var hasTimer: Bool
    @Published internal var whiteTime: Int?
    @Published internal var blackTime: Int?
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
        self.whiteTime = game.whiteTime
        self.blackTime = game.blackTime
        self.canPromotePawnAtPosition = game.canPromotePawnAtPosition
        self.game.delegate = self
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
            self.updateStates()
            self.selectedPosition = nil
            self.allowedMoves = []
        }
    }

    private func updateStates() {
        DispatchQueue.main.async {
            self.state = self.game.state
        }
        self.turn = self.game.turn
        self.kingInCheckForColor = self.game.isKingInCheck(
            forColor: self.turn) ? self.turn : nil
        self.lastMove = self.game.history.last
        self.canPromotePawnAtPosition = self.game.canPromotePawnAtPosition
        self.fen = self.game.fen
        self.whiteCapturedPiece = capturedPieces(for: .white)
        self.blackCapturedPiece = capturedPieces(for: .black)
        self.value = self.game.value
    }

    func updateGame(with newGame: any Game) {
        DispatchQueue.main.async {
            self.game.delegate = nil
            if let newGame = newGame as? ChessGame {
                self.game = newGame
            }
            self.game.delegate = self
            self.whiteTime = self.game.whiteTime
            self.blackTime = self.game.blackTime
            self.selectedPosition = nil
            self.allowedMoves = []
            self.animatedMoves = []
            self.updateStates()

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
        self.game.movePiece(fromPosition: from, toPosition: to)

        self.lastMove = self.game.history.last
        guard let move = self.lastMove,
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
            self.audioPlayerService.playSound(capture: self.lastMove?.capturedPiece != nil)
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
