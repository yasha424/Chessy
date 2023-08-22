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

    let piece: Piece?
    var castling: CastleSide?
    var pawnPromotedTo: PieceType?
    var capturedPiece: Piece?
    var capturedByEnPassant: Bool = false
    var timeLeft: Int?
}

extension Move {
    init(fromString value: String) {
        let index = value.index(value.startIndex, offsetBy: 2)

        self.from = Position.fromString("\(value.prefix(upTo: index))") ?? .a1
        self.to = Position.fromString("\(value.suffix(from: index))") ?? .a1
        self.piece = nil
    }
}

extension Game {

    var fen: String {
        getFen()
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
