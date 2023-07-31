//
//  Game.swift
//  Chessy
//
//  Created by Yasha Serhiienko on 20.07.2023.
//

protocol GameDelegate: AnyObject {
    func didUpdateTime(with time: Int, for color: PieceColor)
}

protocol Game: Equatable, GameTimerDelegate {
    var board: Board { get }
    var history: [Move] { get }
    var turn: PieceColor { get }
    var state: GameState { get }
    var canPromotePawnAtPosition: Position? { get }

    var timer: GameTimer? { get }
    var delegate: GameDelegate? { get set }
    var whiteTime: Int? { get }
    var blackTime: Int? { get }

    func canSelectPiece(atPosition: Position) -> Bool
    func allMoves(fromPosition: Position) -> [Position]
    func movePiece(fromPosition: Position, toPosition: Position)
    func isKingInCheck(forColor: PieceColor) -> Bool
    func addTime(for color: PieceColor)
    func undoLastMove()
    func promotePawn(to type: PieceType)
}

enum GameState: Equatable {
    case checkmate(color: PieceColor)
    case stalemate(color: PieceColor)
    case inProgress
}

enum CastleSide: String {
    case kingSide = "O-O"
    case queenSide = "O-O-O"
}

struct Move: Equatable {
    let from: Position
    let to: Position

    let piece: Piece
    var castling: CastleSide?
    var pawnPromotedTo: PieceType?
    var capturedPiece: Piece?
    var capturedByEnPassant: Bool = false
    var timeLeft: Int?
}

extension Game {

    func canSelectPiece(atPosition position: Position) -> Bool {
        return board[position]?.color == turn
    }

    func addTime(for color: PieceColor) {
        switch color {
        case .white:
            timer?.add(seconds: 15, for: .white)
        case .black:
            timer?.add(seconds: 15, for: .black)
        }
        timer?.start()
    }

}
