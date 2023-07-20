//
//  ImageNames.swift
//  Chessy
//
//  Created by Yasha Serhiienko on 18.07.2023.
//

import Foundation

struct ImageNames {
    static let color = [PieceColor.white: "white_", PieceColor.black: "black_"]
    static let type: [PieceType: String] = [
        .pawn: "pawn",
        .knight: "knight",
        .bishop: "bishop",
        .rook: "rook",
        .queen: "queen",
        .king: "king"
    ]
}
