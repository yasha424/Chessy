//
//  Piece.swift
//  Chessy
//
//  Created by Yasha Serhiienko on 05.07.2023.
//

import Foundation

enum PieceType: String, Identifiable {
    case pawn = "P"
    case bishop = "B"
    case knight = "N"
    case rook = "R"
    case queen = "Q"
    case king = "K"

    var value: Int {
        switch self {
        case .pawn:
            return 1
        case .bishop:
            return 3
        case .knight:
            return 3
        case .rook:
            return 5
        case .queen:
            return 9
        case .king:
            return -1
        }
    }

    var id: String {
        rawValue
    }
}

enum PieceColor: String {
    case white = "W"
    case black = "B"

    var opposite: PieceColor {
        self == .white ? .black : .white
    }
}

struct Piece: Equatable {
    let color: PieceColor
    var type: PieceType

    static func == (lhs: Piece, rhs: Piece) -> Bool {
        return lhs.color == rhs.color && lhs.type == rhs.type
    }

    init(color: PieceColor, type: PieceType) {
        self.color = color
        self.type = type
    }

    init(fromFenCharacter fen: Character) {
        self.color = fen.isUppercase ? .white : .black
        self.type = PieceType(rawValue: fen.uppercased()) ?? .pawn
    }
}
