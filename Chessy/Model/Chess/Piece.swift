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

    var value: Double {
        switch self {
        case .pawn:
            return 1
        case .bishop:
            return 3.05
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
    var intValue: Int {
        return self == .white ? 1 : -1
    }
}

struct Piece: Equatable, Identifiable {
    let color: PieceColor
    var type: PieceType
    private(set) var id: String

    init(color: PieceColor, type: PieceType, id: String = UUID().uuidString) {
        self.color = color
        self.type = type
        self.id = id
    }

    static func == (lhs: Piece, rhs: Piece) -> Bool {
        return lhs.color == rhs.color && lhs.type == rhs.type
    }

    init(fromFenCharacter fen: Character, id: String = UUID().uuidString) {
        self.color = fen.isUppercase ? .white : .black
        self.type = PieceType(rawValue: fen.uppercased()) ?? .pawn
        self.id = id
    }

    mutating func setId(_ id: String) {
        self.id = id
    }
}
