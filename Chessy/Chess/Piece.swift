//
//  Piece.swift
//  Chessy
//
//  Created by Yasha Serhiienko on 05.07.2023.
//

enum PieceType: String {
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
}

enum PieceColor: String {
    case white = "W"
    case black = "B"
}

struct Piece: Equatable {
    let color: PieceColor
    var type: PieceType
    
    static func == (lhs: Piece, rhs: Piece) -> Bool {
        return lhs.color == rhs.color && lhs.type == rhs.type
    }
}
