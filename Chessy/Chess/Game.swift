//
//  Game.swift
//  Chessy
//
//  Created by Yasha Serhiienko on 20.07.2023.
//

import SwiftUI

protocol Game: ObservableObject, Equatable {
    var board: Board { get }
    var history: [Move] { get }
    var turn: PieceColor { get }
    
    func canSelectPiece(atPosition: Position) -> Bool
    func allMoves(fromPosition: Position) -> [Position]
    func movePiece(fromPosition: Position, toPosition: Position) -> Void
    func isKingInCheck(forColor: PieceColor) -> Bool
}

struct Move: Equatable {
    let from: Position
    let to: Position
}

class ClassicGame: Game {

    @Published private(set) var board: Board
 
    private(set) var history = [Move]()
    private(set) var turn: PieceColor = .white

    
    init(board: Board) {
        self.board = board
    }
    
    init(fromFen fen: String) {
        let splittedFen = fen.split(separator: " ")
        
        guard splittedFen.count == 6 else {
            self.board = Board()
            return
        }
        
        self.board = Board(fromFen: String(splittedFen[0]))
        self.turn = splittedFen[1] == "b" ? .black : .white

        if splittedFen[3] != "-",
           let enPassantTargetSquare = Position.fromString("\(splittedFen[3])") {
            let targetSquareX = enPassantTargetSquare.rawValue / 8
            let targetSquareY = enPassantTargetSquare.rawValue % 8
            
            if 2...5 ~= targetSquareX {
                let turn = self.turn == .white ? -1 : 1
                if let from = Position.fromCoordinates(x: targetSquareX - turn, y: targetSquareY),
                   let to = Position.fromCoordinates(x: targetSquareX + turn, y: targetSquareY) {
                    history.append(Move(from: from, to: to))
                }
            }
        }
        
    }
    
    static func == (lhs: ClassicGame, rhs: ClassicGame) -> Bool {
        return lhs.history == rhs.history && lhs.board == rhs.board && lhs.turn == rhs.turn
    }
    
    private func canMove(fromPosition from: Position, toPosition to: Position) -> Bool {
        guard let piece = board[from] else { return false }

        if let otherPiece = board[to] {
            guard otherPiece.color != piece.color else { return false }
        }
        let deltaX = to.rawValue / 8 - from.rawValue / 8
        let deltaY = to.rawValue % 8 - from.rawValue % 8

        switch piece.type {
        case .pawn:
            if !(-2...2 ~= deltaX) || !(-1...1 ~= deltaY) {
                return false
            }
            if isEnPassantAllowed(fromPosition: from, toPosition: to) {
                return true
            }
            switch piece.color {
            case .white:
                if 8..<16 ~= from.rawValue {
                    return (deltaX == 1 && deltaY == 0 && board[to] == nil) ||
                           (deltaX == 2 && deltaY == 0 && board[to] == nil &&
                           !piecesExistBetween(fromPosition: from, toPosition: to)) ||
                           ([-1, 1].contains(deltaX) && deltaX == 1 && board[to]?.color == .black)
                } else {
                    if deltaY == 0 {
                        return board[to] == nil && deltaX == 1
                    } else {
                        return board[to]?.color == .black && deltaX == 1
                    }
                }
            case .black:
                if 48..<56 ~= from.rawValue {
                    return (deltaX == -1 && deltaY == 0 && board[to] == nil) ||
                           (deltaX == -2 && deltaY == 0 && board[to] == nil &&
                           !piecesExistBetween(fromPosition: from, toPosition: to)) ||
                           ([-1, 1].contains(deltaX) && deltaX == -1 && board[to]?.color == .white)
                } else {
                    if deltaY == 0 {
                        return board[to] == nil && deltaX == -1
                    } else {
                        return board[to]?.color == .white && deltaX == -1
                    }
                }
            }
        case .bishop:
            return (abs(deltaX) == abs(deltaY) &&
                    !piecesExistBetween(fromPosition: from, toPosition: to))
        case .knight:
            return [[2, 1], [2, -1], [1, 2], [1, -2],
                    [-1, 2], [-1, -2], [-2, 1], [-2, -1]].contains([deltaX, deltaY])
        case .rook:
            return (deltaX == 0 || deltaY == 0) &&
                    !piecesExistBetween(fromPosition: from, toPosition: to)
        case .queen:
            return (abs(deltaX) == abs(deltaY) || deltaX == 0 || deltaY == 0) &&
                    !piecesExistBetween(fromPosition: from, toPosition: to)
        case .king:
            return (abs(deltaX) <= 1 && abs(deltaY) <= 1) ||
                   (deltaX == 0 && isCastleAllowed(fromPosition: from, toPosition: to))
        }

    }
    
    func movePiece(fromPosition from: Position, toPosition to: Position) {
        guard from != to,
              let piece = board[from],
              turn == piece.color else { return }
        
        let newGame = ClassicGame(board: board)
        newGame.history = history
        
        if canMove(fromPosition: from, toPosition: to) {
            switch piece.type {
            case .pawn where isEnPassantAllowed(fromPosition: from, toPosition: to):
                let otherPiecePositionX = to.rawValue / 8 - (to.rawValue / 8 - from.rawValue / 8)
                let piecePosition = otherPiecePositionX * 8 + (to.rawValue % 8)
                newGame.board.removePiece(atPosition: Position(rawValue: piecePosition) ?? .a1)
//                newGame.board.pieces[otherPiecePositionX * 8 + (to.rawValue % 8)] = nil
            case .king where abs(from.rawValue % 8 - to.rawValue % 8) > 1:
                let isKingSide = to.rawValue % 8 == 6
                let rookPosition = Position(rawValue: to.rawValue / 8 * 8 + (isKingSide ? 7 : 0))!
                let newRookPosition = Position(
                    rawValue: isKingSide ? from.rawValue + 1 : from.rawValue - 1
                )
                newGame.board.movePiece(fromPosition: rookPosition, toPosition: newRookPosition!)
            default:
                break
            }

            newGame.board.movePiece(fromPosition: from, toPosition: to)
            
            switch newGame.board.pieces[to.rawValue]!.color { // promotion
            case .white:
                if piece.type == .pawn && to.rawValue / 8 == 7 {
                    newGame.board.promotePawn(atPosition: to, promoteTo: .queen)
                }
            case .black:
                if piece.type == .pawn && to.rawValue / 8 == 0 {
                    newGame.board.promotePawn(atPosition: to, promoteTo: .queen)
                }
            }
            
            if !newGame.isKingInCheck(forColor: piece.color) {
                self.board = newGame.board
                self.history.append(Move(from: from, to: to))
                self.turn = turn == .white ? .black : .white
            }
        }
        
    }
    
    private func isEnPassantAllowed(fromPosition from: Position, toPosition to: Position) -> Bool {
        guard let piece = board[from],
              piece.type == .pawn,
              let lastMove = history.last,
              abs(lastMove.to.rawValue - lastMove.from.rawValue) == 16,
              let otherPiece = board[lastMove.to],
              otherPiece.type == .pawn,
              piece.color != otherPiece.color else { return false }
        
        let lastMoveX = lastMove.to.rawValue / 8
        let lastMoveY = lastMove.to.rawValue % 8
        let toX = to.rawValue / 8, toY = to.rawValue % 8
        
        guard abs(toX - from.rawValue / 8) == 1 else { return false }
        
        switch piece.color {
        case .white:
            return lastMoveX == toX - 1 && lastMoveY == toY
        case .black:
            return lastMoveX == toX + 1 && lastMoveY == toY
        }
    }

    private func piecesExistBetween(fromPosition from: Position, toPosition to: Position) -> Bool {
        let fromX = from.rawValue / 8, toX = to.rawValue / 8,
            fromY = from.rawValue % 8, toY = to.rawValue % 8
        
        let stepX = fromX < toX ? 1 : (fromX > toX ? -1 : 0)
        let stepY = fromY < toY ? 1 : (fromY > toY ? -1 : 0)

        var positionX = fromX
        var positionY = fromY
        
        positionX += stepX
        positionY += stepY

        while positionX != toX || positionY != toY {
            guard positionX >= 0, positionX < 8,
                  positionY >= 0, positionY < 8 else { return false }
            if board[positionX, positionY] != nil {
                return true
            }
            positionX += stepX
            positionY += stepY
        }
        return false
    }

    private func isCastleAllowed(fromPosition from: Position, toPosition to: Position) -> Bool {
        guard let piece = board[from],
              piece.type == .king else { return false }
        
        let fromX = from.rawValue / 8, fromY = from.rawValue % 8
        let toX = to.rawValue / 8, toY = to.rawValue % 8
        
        guard fromY == 4, [2, 6].contains(toY),
              fromX == toX,
              !pieceHasMoved(atPosition: from),
              !piecesExistBetween(fromPosition: from, toPosition: to) else { return false }

        if piece.color == .white {
            if piecesExistBetween(fromPosition: from, toPosition: toY == 6 ? .h1 : .a1) ||
               fromX != 0 || toX != 0 { return false }
            
            if !pieceHasMoved(atPosition: Position(rawValue: toY == 6 ? 7 : 0)!) {
                let positions: [Position] = toY == 6 ? [.e1, .f1, .g1] : [.c1, .d1, .e1]
                return !positions.contains(where: { isPositionThreatened($0, byColor: .black) })
            }
        } else {
            if piecesExistBetween(fromPosition: from, toPosition: toY == 6 ? .h8 : .a8) ||
               fromX != 7 || toX != 7 { return false }
            
            if !pieceHasMoved(atPosition: Position(rawValue: toY == 6 ? 63 : 56)!) {
                let positions: [Position] = toY == 6 ? [.e8, .f8, .g8] : [.c8, .d8, .e8]
                return !positions.contains(where: { isPositionThreatened($0, byColor: .white) })
            }
        }
        return false
    }
    
    private func pieceHasMoved(atPosition position: Position) -> Bool {
        return history.contains(where: { $0.from == position || $0.to == position })
    }

    private func isPositionThreatened(_ position: Position?, byColor color: PieceColor) -> Bool {
        guard let position = position else { return false }
        
        return Position.allCases.contains { from in
            if let piece = board[from] {
                guard piece.color == color else { return false }
                
                if piece.type == .pawn {
                    let deltaX = position.rawValue / 8 - from.rawValue / 8
                    let deltaY = position.rawValue % 8 - from.rawValue % 8

                    switch piece.color {
                    case .white:
                        return deltaX == 1 && [-1, 1].contains(deltaY) &&
                           position.rawValue / 8 == from.rawValue / 8 + 1
                    case .black:
                        return deltaX == -1 && [-1, 1].contains(deltaY) &&
                           position.rawValue / 8 == from.rawValue / 8 - 1
                    }
                } else {
                    return canMove(fromPosition: from, toPosition: position)
                }
            }
            return false
        }
    }

    func isKingInCheck(forColor color: PieceColor) -> Bool {
        return isPositionThreatened(getKingPosition(forColor: color),
                                    byColor: color == .white ? .black : .white)
    }

    private func getKingPosition(forColor color: PieceColor) -> Position? {
        return Position.allCases.first(where: { position in
            if let piece = board[position] {
                if piece.color == color && piece.type == .king {
                    return true
                }
            }
            return false
        })
    }

    func allMoves(fromPosition position: Position) -> [Position] {
        guard let piece = board[position] else { return [] }

        return Position.allCases.filter {
            let newGame = ClassicGame(board: board)
            newGame.board.movePiece(fromPosition: position, toPosition: $0)

            return canMove(fromPosition: position, toPosition: $0) &&
                   !newGame.isKingInCheck(forColor: piece.color)
        }
    }
    
    func canSelectPiece(atPosition position: Position) -> Bool {
        return board[position]?.color == turn
    }

}
