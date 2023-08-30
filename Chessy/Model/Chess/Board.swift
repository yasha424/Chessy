//
//  Board.swift
//  Chessy
//
//  Created by Yasha Serhiienko on 05.07.2023.
//

enum Position: Int, CaseIterable {
    case a1; case b1; case c1; case d1; case e1; case f1; case g1; case h1
    case a2; case b2; case c2; case d2; case e2; case f2; case g2; case h2
    case a3; case b3; case c3; case d3; case e3; case f3; case g3; case h3
    case a4; case b4; case c4; case d4; case e4; case f4; case g4; case h4
    case a5; case b5; case c5; case d5; case e5; case f5; case g5; case h5
    case a6; case b6; case c6; case d6; case e6; case f6; case g6; case h6
    case a7; case b7; case c7; case d7; case e7; case f7; case g7; case h7
    case a8; case b8; case c8; case d8; case e8; case f8; case g8; case h8

    var x: Int { rawValue / 8 }
    var y: Int { rawValue % 8 }
    var file: String {
        "\("\(self)".first!)"
    }
    var rank: String {
        "\(x + 1)"
    }

    static func fromCoordinates(x: Int, y: Int) -> Position? {
        Position(rawValue: x * 8 + y)
    }

    static func fromString(_ value: String) -> Position? {
        Position.allCases.first { value == "\($0)" }
    }

    static func - (lhs: Position, rhs: Position) -> Position? {
        return Position(rawValue: lhs.rawValue - rhs.rawValue)
    }

    static func - (lhs: Position, rhs: Int) -> Position? {
        return Position(rawValue: lhs.rawValue - rhs)
    }

    static func + (lhs: Position, rhs: Position) -> Position? {
        return Position(rawValue: lhs.rawValue + rhs.rawValue)
    }

    static func + (lhs: Position, rhs: Int) -> Position? {
        return Position(rawValue: lhs.rawValue + rhs)
    }
}

struct Board: Equatable {
    private(set) var pieces: [Piece?] = Array(repeating: nil, count: 64)

    init() {
        defaultSetup()
    }

    init(fromFen fen: String) {
        let rows = fen.split(separator: "/")

        guard rows.count == 8 else {
            defaultSetup()
            return
        }

        for i in 0..<8 {
            var count = 0
            for fenCharacter in rows[7 - i] {
                if let emptyCells = Int("\(fenCharacter)") {
                    count += emptyCells

                    guard count <= 8 else {
                        defaultSetup()
                        return
                    }

                    for j in 0..<emptyCells {
                        pieces[i * 8 + count - emptyCells + j] = nil
                    }
                } else {
                    count += 1

                    guard count <= 8 else {
                        defaultSetup()
                        return
                    }

                    pieces[i * 8 + count - 1] = Piece(fromFenCharacter: fenCharacter)
                }
            }
            guard count == 8 else {
                defaultSetup()
                return
            }
            setPiecesIds()
        }
    }

    private mutating func setPiecesIds() {
        var piecesCount: [PieceColor: [PieceType: Int]] = [
            .white: [
                .pawn: 0,
                .knight: 0,
                .bishop: 0,
                .rook: 0,
                .queen: 0,
                .king: 0
            ],
            .black: [
                .pawn: 0,
                .knight: 0,
                .bishop: 0,
                .rook: 0,
                .queen: 0,
                .king: 0
            ]
        ]

        for (i, piece) in pieces.enumerated() where piece != nil {
            guard let piece = piece else { return }
            pieces[i]!.setId(piece.color.rawValue + piece.type.rawValue +
                             String(piecesCount[piece.color]![piece.type]!))
            piecesCount[piece.color]![piece.type]! += 1
        }
    }

    private mutating func defaultSetup() {
        let pieceTypes: [(PieceType, Int)] = [
            (.rook, 0), (.knight, 0), (.bishop, 0), (.queen, 0),
            (.king, 0), (.bishop, 1), (.knight, 1), (.rook, 1)
        ]

        // white setup
        (0..<8).forEach { i in
            var piece = Piece(color: .white, type: pieceTypes[i].0)
            piece.setId(piece.color.rawValue + piece.type.rawValue + "\(pieceTypes[i].1)")
            pieces[i] = piece
        }
        (8..<16).forEach { i in
            pieces[i] = Piece(color: .white, type: .pawn, id: "WP\(i - 8)")
        }

        (16..<48).forEach { i in
            pieces[i] = nil
        }

        // black setup
        (48..<56).forEach { i in
            pieces[i] = Piece(color: .black, type: .pawn, id: "BP\(i - 48)")
        }
        (56..<64).forEach { i in
            var piece = Piece(color: .black, type: pieceTypes[i - 56].0)
            piece.setId(piece.color.rawValue + piece.type.rawValue + "\(pieceTypes[i - 56].1)")
            pieces[i] = piece
        }
    }

    subscript(i: Position) -> Piece? {
        return pieces[i.rawValue]
    }

    subscript(i: Int) -> Piece? {
        return pieces[i]
    }

    subscript(x: Int, y: Int) -> Piece? {
        guard x < 8, y < 8 else { return nil }
        return pieces[x * 8 + y]
    }

    static func == (lhs: Board, rhs: Board) -> Bool {
        guard lhs.pieces.count == 64, rhs.pieces.count == 64 else { return false }

        for i in 0..<64 where lhs.pieces[i] != rhs.pieces[i] {
            return false
        }

        return true
    }

    mutating func movePiece(fromPosition from: Position, toPosition to: Position) {
        guard from != to,
              self[from] != nil else { return }

        pieces.swapAt(from.rawValue, to.rawValue)
        pieces[from.rawValue] = nil
    }

    mutating func removePiece(atPosition position: Position) {
        pieces[position.rawValue] = nil
    }

    mutating func addPiece(_ piece: Piece, atPosition position: Position) {
        guard pieces[position.rawValue] == nil else { return }
        pieces[position.rawValue] = piece
    }

    mutating func promotePawn(atPosition position: Position, promoteTo type: PieceType) {
        guard let piece = pieces[position.rawValue],
              piece.type == .pawn,
              type != .pawn, type != .king else { return }

        guard (position.x == 7 && piece.color == .white) ||
              (position.x == 0 && piece.color == .black) else { return }

        pieces[position.rawValue] = Piece(color: piece.color, type: type)
    }
}
