//
//  Board.swift
//  Chessy
//
//  Created by Yasha Serhiienko on 05.07.2023.
//

import SwiftUI

enum Position: Int, CaseIterable {
    case a1; case b1; case c1; case d1; case e1; case f1; case g1; case h1
    case a2; case b2; case c2; case d2; case e2; case f2; case g2; case h2
    case a3; case b3; case c3; case d3; case e3; case f3; case g3; case h3
    case a4; case b4; case c4; case d4; case e4; case f4; case g4; case h4
    case a5; case b5; case c5; case d5; case e5; case f5; case g5; case h5
    case a6; case b6; case c6; case d6; case e6; case f6; case g6; case h6
    case a7; case b7; case c7; case d7; case e7; case f7; case g7; case h7
    case a8; case b8; case c8; case d8; case e8; case f8; case g8; case h8
}

struct Move: Equatable {
    let from: Position
    let to: Position
}

class Board: Equatable, ObservableObject {
    
    @Published var pieces = [Piece?]()
    @Published var history = [Move]()
    var turn: PieceColor = .white
    
    init() {

        let pieceTypes: [PieceType] = [
            .rook, .knight, .bishop, .queen, .king, .bishop, .knight, .rook
        ]

        // white setup
        for i in 0..<8 {
            pieces.append(Piece(color: .white, type: pieceTypes[i]))
        }
        (8..<16).forEach { _ in
            pieces.append(Piece(color: .white, type: .pawn))
        }

        (16..<48).forEach { _ in
            pieces.append(nil)
        }
        
        // black setup
        (48..<56).forEach { _ in
            pieces.append(Piece(color: .black, type: .pawn))
        }
        for i in 56..<64 {
            pieces.append(Piece(color: .black, type: pieceTypes[i - 56]))
        }

    }
    
    subscript(i: Position) -> Piece? {
        return pieces[i.rawValue]
    }
    
    subscript(x: Int, y: Int) -> Piece? {
        guard x < 8, y < 8 else { return nil }
        return pieces[x * 8 + y]
    }
    
    static func == (lhs: Board, rhs: Board) -> Bool {
        guard lhs.pieces.count == 64, rhs.pieces.count == 64 else { return false }
        
        for i in 0..<64 {
            if lhs.pieces[i] != rhs.pieces[i] { return false }
        }
        
        return true
    }
    
    func display() {
        let x: Int = 7
        (0..<8).forEach { i in
            (0..<8).forEach { j in
                if let piece = self[x - i, j] {
                    print(
                        piece.color.rawValue,
                        piece.type.rawValue,
                        separator: "",
                        terminator: " "
                    )
                } else { print("  ", terminator: " ") }
            }
            print()
        }
    }
    
    private func getPiece(atPosition position: Position) -> Piece? {
        return pieces[position.rawValue]
    }
    
    func movePiece(fromPosition from: Position, toPosition to: Position) {
        guard from != to,
              let piece = self[from],
              turn == piece.color else { return }
        
        let newBoard = Board()
        newBoard.history = history
        newBoard.pieces = pieces
        
        if canMove(fromPosition: from, toPosition: to) {
            switch piece.type {
            case .pawn where isEnPassantAllowed(fromPosition: from, toPosition: to):
                let otherPiecePositionX = to.rawValue / 8 - (to.rawValue / 8 - from.rawValue / 8)
                newBoard.pieces[otherPiecePositionX * 8 + (to.rawValue % 8)] = nil
            case .king where abs(from.rawValue % 8 - to.rawValue % 8) > 1:
                let kingSide = to.rawValue % 8 == 6
                let rookPosition = Position(rawValue: to.rawValue / 8 * 8 + (kingSide ? 7 : 0))!
                newBoard.pieces[kingSide ? from.rawValue + 1 : from.rawValue - 1] = self[rookPosition]
                newBoard.pieces[rookPosition.rawValue] = nil
                newBoard.pieces[to.rawValue] = piece
            default:
                break
            }

            newBoard.pieces[to.rawValue] = piece
            newBoard.pieces[from.rawValue] = nil
            
            switch newBoard.pieces[to.rawValue]!.color {
            case .white:
                if piece.type == .pawn && to.rawValue / 8 == 7 {
                    newBoard.pieces[to.rawValue] = Piece(color: .white, type: .queen)
                }
            case .black:
                if piece.type == .pawn && to.rawValue / 8 == 0 {
                    newBoard.pieces[to.rawValue] = Piece(color: .black, type: .queen)
                }
            }
            
            if !newBoard.isKingInCheck(forColor: piece.color) {
                self.pieces = newBoard.pieces
                self.history.append(Move(from: from, to: to))
                turn = turn == .white ? .black : .white
            }
        }
        
    }
    
    func canSelectPiece(atPosition position: Position) -> Bool {
        return getPiece(atPosition: position)?.color == turn
    }
    
    func canMove(fromPosition from: Position, toPosition to: Position) -> Bool {
        
        guard let piece = getPiece(atPosition: from) else { return false }

        if let otherPiece = self[to] {
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
                    return (1...2 ~= deltaX && deltaY == 0 && self[to] == nil) ||
                           ([-1, 1].contains(deltaX) && deltaX == 1 && self[to]?.color == .black)
                } else {
                    if deltaY == 0 {
                        return self[to] == nil && deltaX == 1
                    } else {
                        return self[to]?.color == .black && deltaX == 1
                    }
                }
            case .black:
                if 48..<56 ~= from.rawValue {
                    return (-2 ... -1 ~= deltaX && deltaY == 0 && self[to] == nil) ||
                           ([-1, 1].contains(deltaX) && deltaX == -1 && self[to]?.color == .white)
                } else {
                    if deltaY == 0 {
                        return self[to] == nil && deltaX == -1
                    } else {
                        return self[to]?.color == .white && deltaX == -1
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
                   isCastleAllowed(fromPosition: from, toPosition: to)
        }

    }
    
    func piecesExistBetween(fromPosition from: Position, toPosition to: Position) -> Bool {
        let fromX = from.rawValue / 8, toX = to.rawValue / 8,
            fromY = from.rawValue % 8, toY = to.rawValue % 8
        
        let stepX = fromX < toX ? 1 : (fromX > toX ? -1 : 0)
        let stepY = fromY < toY ? 1 : (fromY > toY ? -1 : 0)

        var positionX = fromX
        var positionY = fromY
        
        positionX += stepX
        positionY += stepY

        while positionX != toX || positionY != toY {
            if self[positionX, positionY] != nil {
                return true
            }
            positionX += stepX
            positionY += stepY
        }
        return false
    }
    
    private func isKingInCheck(forColor color: PieceColor) -> Bool {
        return isPieceThreatened(atPosittion: getKingPosition(forColor: color))
    }
    
    private func getKingPosition(forColor color: PieceColor) -> Position? {
        return Position.allCases.first(where: { position in
            if let piece = getPiece(atPosition: position) {
                if piece.color == color && piece.type == .king {
                    return true
                }
            }
            return false
        })
    }
    
    private func isPieceThreatened(atPosittion position: Position?) -> Bool {
        guard let position = position else { return false }
        
        return Position.allCases.contains(where: {
            canMove(fromPosition: $0, toPosition: position)
        })
    }
    
    func isPositionThreatened(_ position: Position, byColor color: PieceColor) -> Bool {
        return Position.allCases.contains { from in
            if let piece = getPiece(atPosition: from) {
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
    
    private func isCastleAllowed(fromPosition from: Position, toPosition to: Position) -> Bool {
        guard let piece = self[from], piece.type == .king else { return false }
        
        let fromX = from.rawValue / 8, fromY = from.rawValue % 8
        let toX = to.rawValue / 8, toY = to.rawValue % 8
        
        guard fromY == 4, [2, 6].contains(toY), !pieceHasMoved(atPosition: from) else {
            return false
        }

        if piece.color == .white {
            if fromX != 0 || toX != 0 { return false }
            
            if !pieceHasMoved(atPosition: Position(rawValue: toY == 6 ? 7 : 0)!) {
                let positions: [Position] = toY == 6 ? [.f1, .g1] : [.d1, .c1]
                return !positions.contains(where: { isPositionThreatened($0, byColor: .black) })
            }
        } else {
            if fromX != 7 || toX != 7 { return false }
            
            if !pieceHasMoved(atPosition: Position(rawValue: toY == 6 ? 63 : 56)!) {
                let positions: [Position] = toY == 6 ? [.f8, .g8] : [.d8, .c8]
                return !positions.contains(where: { isPositionThreatened($0, byColor: .white) })
            }
        }
        return false
    }
    
    private func pieceHasMoved(atPosition position: Position) -> Bool {
        return history.contains(where: { $0.from == position })
    }
    
    func allMoves(fromPosition position: Position) -> [Position] {
        Position.allCases.filter { canMove(fromPosition: position, toPosition: $0) }
    }
    
    func isEnPassantAllowed(fromPosition from: Position, toPosition to: Position) -> Bool {
        guard let piece = self[from],
              piece.type == .pawn,
              let lastMove = history.last,
              abs(lastMove.to.rawValue - lastMove.from.rawValue) == 16,
              let otherPiece = self[lastMove.to],
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
    
    func isCheckmate() -> Bool {
        return false
    }
}
