//
//  Game.swift
//  Chessy
//
//  Created by Yasha Serhiienko on 20.07.2023.
//

import Foundation

protocol GameDelegate: AnyObject {
    func didUpdateTime(with time: Int, for color: PieceColor)
}

protocol Game: Equatable, GameTimerDelegate {
    var board: Board { get set }
    var history: [Move] { get }
    var turn: PieceColor { get set }
    var state: GameState { get }
    var canPromotePawnAtPosition: Position? { get }

    var timer: GameTimer? { get }
    var delegate: GameDelegate? { get set }
    var whiteTime: Int? { get }
    var blackTime: Int? { get }

    init(board: Board)
    func canMove(fromPosition: Position, toPosition: Position) -> Bool
    func canSelectPiece(atPosition: Position) -> Bool
    func allMoves(fromPosition: Position) -> [Position]
    func movePiece(fromPosition: Position, toPosition: Position)
    func isKingInCheck(forColor: PieceColor) -> Bool
    func addTime(for color: PieceColor)
    func undoLastMove()
    func promotePawn(to type: PieceType)
    func getState() -> GameState
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

    let piece: Piece?
    var castling: CastleSide?
    var pawnPromotedTo: PieceType?
    var capturedPiece: Piece?
    var capturedByEnPassant: Bool = false
    var timeLeft: Int?
}

extension Move {
    init(fromString value: String) {
        var index = value.index(value.startIndex, offsetBy: 2)

        self.from = Position.fromString("\(value.prefix(upTo: index))") ?? .a1
        var newValue = value.dropFirst().dropFirst()
        index = newValue.index(newValue.startIndex, offsetBy: 2)
        self.to = Position.fromString("\(newValue.prefix(upTo: index))") ?? .a1
        newValue = newValue.dropFirst().dropFirst()
        if !newValue.isEmpty {
            pawnPromotedTo = PieceType(rawValue: String(newValue.first?.uppercased() ?? "Q"))
        }
        self.piece = nil
    }
}

extension Game {

    var fen: String {
        getFen()
    }

    var value: Int {
        return countValue()
    }

    init(fromPGN pgn: String) {
        self.init(board: Board())
        if let pgnHistory = try? NSRegularExpression(pattern: "[0-9]+\\. ").splitn(pgn) {
            for pgnMoves in pgnHistory {
                let moves = pgnMoves.split(separator: " ")
                for pgnMove in moves {
                    let pgnMove = pgnMove
                        .replacingOccurrences(of: "+", with: "")
                        .replacingOccurrences(of: "#", with: "")
                        .replacingOccurrences(of: "x", with: "")

                    if let move = getMoveFromPgn(String(pgnMove)) {
                        self.movePiece(fromPosition: move.from, toPosition: move.to)
                        if let promotionType = move.pawnPromotedTo {
                            self.promotePawn(to: promotionType)
                        }
                    } else {
                        return
                    }
                }
            }
        }
    }

    private func getMoveFromPgn(_ pgn: String) -> Move? {
        guard let firstCharacter = pgn.first else { return nil }
        if firstCharacter == "O" {
            return getCastlingMoveFromPgn(pgn)
        } else if firstCharacter.isUppercase {
            return getFigureMoveFromPgn(firstCharacter: String(firstCharacter), pgn)
        } else {
            return getPawnMoveFromPgn(pgn)
        }
    }

    private func getFigureMoveFromPgn(firstCharacter: String, _ pgn: String) -> Move? {
        guard pgn.count >= 3,
              let to = Position.fromString(String(pgn[pgn.count-2..<pgn.count])) else { return nil }
        let positions = board.getPiecesPosition(with: String(firstCharacter), color: turn)

        for position in positions where canMove(fromPosition: position, toPosition: to) {
            if pgn.count == 3 {
                return Move(from: position, to: to, piece: nil)
            } else if pgn.count == 4 {
                if let rank = Int(pgn[1]) {
                    if position.rank == String(rank) {
                        return Move(from: position, to: to, piece: nil)
                    }
                } else {
                    let file = pgn[1]
                    if position.file == file {
                        return Move(from: position, to: to, piece: nil)
                    }
                }
            } else if pgn.count == 5 {
                let file = pgn[1]
                let rank = pgn[2]
                if position.file == file, position.rank == rank {
                    return Move(from: position, to: to, piece: nil)
                }
            }
        }
        return nil
    }

    private func getPawnMoveFromPgn(_ pgn: String) -> Move? {
        guard let lastCharacter = pgn.last else { return nil }

        // TODO: handle multiple pawns promotion from different positions
        if lastCharacter.isUppercase {
            guard pgn.count == 3,
                  let to = Position.fromString(pgn[pgn.count-3..<pgn.count-1]) else { return nil }
            let positions = board.getPiecesPosition(with: "P", color: turn)
            for position in positions where canMove(fromPosition: position, toPosition: to) {
                return Move(from: position, to: to, piece: nil,
                            pawnPromotedTo: PieceType.init(rawValue: String(lastCharacter)))
            }
        } else {
            guard pgn.count >= 2,
                  let to = Position.fromString(pgn[pgn.count-2..<pgn.count]) else { return nil }

            let positions = board.getPiecesPosition(with: "P", color: turn)
            for position in positions where canMove(fromPosition: position, toPosition: to) {
                return Move(from: position, to: to, piece: nil)
            }
        }
        return nil
    }

    private func getCastlingMoveFromPgn(_ pgn: String) -> Move? {
        if pgn == "O-O" {
            let positions = board.getPiecesPosition(with: "K", color: turn)
            for position in positions {
                let to: Position = turn == .white ? .g1 : .g8
                if canMove(fromPosition: position, toPosition: to) {
                    return Move(from: position, to: to, piece: nil)
                }
            }
        } else if pgn == "O-O-O" {
            let positions = board.getPiecesPosition(with: "K", color: turn)
            for position in positions {
                let to: Position = turn == .white ? .c1 : .c8
                if canMove(fromPosition: position, toPosition: to) {
                    return Move(from: position, to: to, piece: nil)
                }
            }
        }
        return nil
    }

    private func countValue() -> Int {
         return board.pieces.reduce(0) { partialResult, piece in
             if let piece = piece {
                 return partialResult + Int(piece.type.value) * piece.color.intValue
             }
             return partialResult
        }
    }

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

    func pieceHasMoved(atPosition position: Position) -> Bool {
        return history.contains(where: { $0.from == position || $0.to == position })
    }

    private func getFen() -> String {
        var fen = ""

        for i in 0..<8 {
            var emptySquares = 0
            for j in 0..<8 {
                if let piece = board[(7 - i) * 8 + j] {
                    fen += emptySquares > 0 ? "\(emptySquares)" : ""
                    emptySquares = 0
                    if piece.color == .black {
                        fen += piece.type.rawValue.lowercased()
                    } else {
                        fen += piece.type.rawValue
                    }
                } else {
                    emptySquares += 1
                }
            }
            fen += emptySquares > 0 ? "\(emptySquares)/" : "/"
        }

        fen.removeLast()
        fen += turn == .white ? " w " : " b "
        fen += getCastlingSidesInString()
        if let lastMove = history.last, let piece = lastMove.piece,
           piece.type == .pawn, abs(lastMove.to.x - lastMove.from.x) == 2 {
            if piece.color == .white {
                if let position = Position.fromCoordinates(x: 2, y: lastMove.to.y) {
                    fen += " \(position)"
                }
            } else {
                if let position = Position.fromCoordinates(x: 5, y: lastMove.to.y) {
                    fen += " \(position)"
                }
            }
        } else {
            fen += " -"
        }

        fen += " 0 0"

        return fen
    }

    private func getCastlingSidesInString() -> String {
        let whiteKing = Piece(color: .white, type: .king),
            blackKing = Piece(color: .black, type: .king)
        let castlingMoves = [
            Move(from: .e1, to: .g1, piece: whiteKing, castling: .kingSide),
            Move(from: .e1, to: .b1, piece: whiteKing, castling: .queenSide),
            Move(from: .e8, to: .g8, piece: blackKing, castling: .kingSide),
            Move(from: .e8, to: .b8, piece: blackKing, castling: .queenSide)
        ]

        var castlingSides = ""
        var castleIsAllowed = false
        for move in castlingMoves where !pieceHasMoved(atPosition: move.from) {
            let rookPosition = Position.fromCoordinates(
                x: move.from.x,
                y: move.castling == .kingSide ? 7 : 0
            )
            if let position = rookPosition, !pieceHasMoved(atPosition: position) {
                castleIsAllowed = true
                if move.castling == .kingSide {
                    castlingSides += move.piece?.color == .white ? "K" : "k"
                } else {
                    castlingSides += move.piece?.color == .white ? "Q" : "q"
                }
            }
        }
        castlingSides += castleIsAllowed ? "" : "-"
        return castlingSides
    }
}
