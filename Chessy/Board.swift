//
//  Board.swift
//  Chessy
//
//  Created by Yasha Serhiienko on 05.07.2023.
//

import SwiftUI

enum Position: Int {
    case a1; case b1; case c1; case d1; case e1; case f1; case g1; case h1
    case a2; case b2; case c2; case d2; case e2; case f2; case g2; case h2
    case a3; case b3; case c3; case d3; case e3; case f3; case g3; case h3
    case a4; case b4; case c4; case d4; case e4; case f4; case g4; case h4
    case a5; case b5; case c5; case d5; case e5; case f5; case g5; case h5
    case a6; case b6; case c6; case d6; case e6; case f6; case g6; case h6
    case a7; case b7; case c7; case d7; case e7; case f7; case g7; case h7
    case a8; case b8; case c8; case d8; case e8; case f8; case g8; case h8
}

class Board: Equatable, ObservableObject {
    
    @Published private var pieces = [Piece?]()
    
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
              let piece = self[from] else { return }
        
        if canMove(fromPosition: from, toPosition: to) {
            pieces[to.rawValue] = piece
            pieces[from.rawValue] = nil
        }
        
    }
    
    func canMove(fromPosition from: Position, toPosition to: Position) -> Bool {
        
        guard let piece = getPiece(atPosition: from) else { return false }

        if let otherPiece = self[to] {
            guard otherPiece.color != piece.color else { return false }
        }
        let deltaX = to.rawValue / 8 - from.rawValue / 8
        let deltaY = to.rawValue % 8 - from.rawValue % 8
        print(deltaX, deltaY)

        switch piece.type {
        case .pawn:
            if !(-2...2 ~= deltaX) || !(-1...1 ~= deltaY) {
                return false
            }
            switch piece.color {
            case .white:
                if 8..<16 ~= from.rawValue {
                    return 1...2 ~= deltaX
                } else {
                    if deltaY == 0 {
                        return deltaX == 1
                    } else {
                        return self[to]?.color == .black
                    }
                }
            case .black:
                if 48..<56 ~= from.rawValue {
                    return -2 ... -1 ~= deltaX
                } else {
                    if deltaY == 0 {
                        return deltaX == -1
                    } else {
                        return self[to]?.color == .white
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
            return abs(deltaX) <= 1 && abs(deltaY) <= 1
        }
        
        
        return true
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
}
