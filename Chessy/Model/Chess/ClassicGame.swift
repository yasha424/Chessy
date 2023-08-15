//
//  ClassicGame.swift
//  Chessy
//
//  Created by Yasha Serhiienko on 27.07.2023.
//

class ClassicGame: Game {

    internal var board: Board
    private(set) var history = [Move]()
    private(set) var turn: PieceColor = .white
    weak var delegate: GameDelegate?

    private(set) var timer: GameTimer?
    private(set) var whiteTime: Int?
    private(set) var blackTime: Int?

    private(set) var state: GameState = .inProgress
    private(set) var canPromotePawnAtPosition: Position?

    init(board: Board) {
        self.board = board
        setupTimer(seconds: 30)
    }

    init(fromFen fen: String) {
        let splittedFen = fen.split(separator: " ")

        guard splittedFen.count == 6 else {
            self.board = Board()
            setupTimer(seconds: 30)
            return
        }

        self.board = Board(fromFen: String(splittedFen[0]))
        self.turn = splittedFen[1] == "b" ? .black : .white

        if splittedFen[3] != "-",
           let enPassantTargetSquare = Position.fromString("\(splittedFen[3])"),
           [2, 5].contains(enPassantTargetSquare.x) {
            let turn = self.turn == .white ? -8 : 8
            if let from = enPassantTargetSquare - turn,
               let to = enPassantTargetSquare + turn,
               let piece = board[to] {
                history.append(Move(from: from, to: to, piece: piece, timeLeft: 30))
            }
        }

        setupTimer(seconds: 30)
        timer?.start()
        canPromotePawnAtPosition = getPawnPromotePosition()
        if canPromotePawnAtPosition == nil {
            updateStateAndTimer(game: self)
        }
    }

    private func setupTimer(seconds: Int) {
        timer = GameTimer(seconds: seconds)
        whiteTime = timer?.whiteSeconds
        blackTime = timer?.blackSeconds
        timer?.delegate = self
    }

    private func getState() -> GameState {
        if !allMoves(for: turn).isEmpty {
            return .inProgress
        } else {
            if isKingInCheck(forColor: turn) {
                return .checkmate(color: turn)
            } else {
                return .stalemate(color: turn)
            }
        }
    }

    static func == (lhs: ClassicGame, rhs: ClassicGame) -> Bool {
        return lhs.history == rhs.history && lhs.board == rhs.board && lhs.turn == rhs.turn
    }

    private func canMove(fromPosition from: Position, toPosition to: Position) -> Bool {
        guard let piece = board[from],
              canPromotePawnAtPosition == nil else { return false }

        if let otherPiece = board[to] {
            guard otherPiece.color != piece.color else { return false }
        }

        switch piece.type {
        case .pawn:
            return pawnCanMove(piece, from: from, to: to)
        case .bishop:
            return abs(to.x - from.x) == abs(to.y - from.y) &&
                !piecesExistBetween(fromPosition: from, toPosition: to)
        case .knight:
            return [[2, 1], [2, -1], [1, 2], [1, -2],
                    [-1, 2], [-1, -2], [-2, 1], [-2, -1]].contains([to.x - from.x, to.y - from.y])
        case .rook:
            return (to.x - from.x == 0 || to.y - from.y == 0) &&
                !piecesExistBetween(fromPosition: from, toPosition: to)
        case .queen:
            return (abs(to.x - from.x) == abs(to.y - from.y) || to.x - from.x == 0
                   || to.y - from.y == 0) && !piecesExistBetween(fromPosition: from, toPosition: to)
        case .king:
            return (abs(to.x - from.x) <= 1 && abs(to.y - from.y) <= 1) ||
                (to.x - from.x == 0 && isCastleAllowed(fromPosition: from, toPosition: to))
        }
    }

    private func pawnCanMove(_ piece: Piece, from: Position, to: Position) -> Bool {
        if !(-2...2 ~= to.x - from.x) || !(-1...1 ~= to.y - from.y) {
            return false
        }
        if isEnPassantAllowed(fromPosition: from, toPosition: to) {
            return true
        }
        switch piece.color {
        case .white:
            if 8..<16 ~= from.rawValue {
                return (to.x - from.x == 1 && to.y - from.y == 0 && board[to] == nil) ||
                       (to.x - from.x == 2 && to.y - from.y == 0 && board[to] == nil &&
                       !piecesExistBetween(fromPosition: from, toPosition: to)) ||
                       ([-1, 1].contains(to.x - from.x) && to.x - from.x == 1 &&
                       board[to]?.color == .black)
            } else {
                if to.y - from.y == 0 {
                    return board[to] == nil && to.x - from.x == 1
                } else {
                    return board[to]?.color == .black && to.x - from.x == 1
                }
            }
        case .black:
            if 48..<56 ~= from.rawValue {
                return (to.x - from.x == -1 && to.y - from.y == 0 && board[to] == nil) ||
                       (to.x - from.x == -2 && to.y - from.y == 0 && board[to] == nil &&
                       !piecesExistBetween(fromPosition: from, toPosition: to)) ||
                       ([-1, 1].contains(to.x - from.x) && to.x - from.x == -1 &&
                       board[to]?.color == .white)
            } else {
                if to.y - from.y == 0 {
                    return board[to] == nil && to.x - from.x == -1
                } else {
                    return board[to]?.color == .white && to.x - from.x == -1
                }
            }
        }
    }

    func movePiece(fromPosition from: Position, toPosition to: Position) {
        guard from != to,
              let piece = board[from],
              turn == piece.color else { return }

        let newGame = ClassicGame(board: board)
        newGame.history = history
        var castling: CastleSide?
        var capturedByEnPassant = false
        var capturedPiece: Piece?

        if canMove(fromPosition: from, toPosition: to) {
            capturedPiece = board[to]
            newGame.board.movePiece(fromPosition: from, toPosition: to)

            switch piece.type {
            case .pawn where isEnPassantAllowed(fromPosition: from, toPosition: to):
                let otherPiecePosition = (to.x - (to.x - from.x)) * 8 + (to.y)
                if let position = Position(rawValue: otherPiecePosition) {
                    capturedPiece = board[position]
                    capturedByEnPassant = true
                    newGame.board.removePiece(atPosition: position)
                }
            case .king where abs(from.rawValue % 8 - to.rawValue % 8) > 1:
                castling = to.y == 6 ? .kingSide : .queenSide
                castle(game: newGame, side: castling!, from: from)
            default:
                break
            }

            if !newGame.isKingInCheck(forColor: piece.color) {
                finishMove(
                    game: newGame,
                    from: from,
                    to: to,
                    castling: castling,
                    capturedPiece: capturedPiece,
                    capturedByEnPassant: capturedByEnPassant
                )
            }
        }
    }

    private func finishMove(game: ClassicGame, from: Position, to: Position, castling: CastleSide?,
                            capturedPiece: Piece?, capturedByEnPassant: Bool) {

        canPromotePawnAtPosition = game.getPawnPromotePosition()
        if canPromotePawnAtPosition == nil {
            game.turn = turn.opposite
            timer?.add(seconds: 3, for: turn)
            timer?.start()

            updateStateAndTimer(game: game)
            turn = game.turn
        }

        history.append(Move(
            from: from,
            to: to,
            piece: board[from]!,
            castling: castling,
            capturedPiece: capturedPiece,
            capturedByEnPassant: capturedByEnPassant,
            timeLeft: turn == .white ? whiteTime : blackTime
        ))
        board = game.board
    }

    private func getPawnPromotePosition() -> Position? {
        for i in 56..<64 {
            if board[i]?.type == .pawn && board[i]?.color == .white {
                return Position(rawValue: i)
            }
        }
        for i in 0..<8 {
            if board[i]?.type == .pawn && board[i]?.color == .black {
                return Position(rawValue: i)
            }
        }
        return nil
    }

    func promotePawn(to type: PieceType) {
        if let pawnPosition = canPromotePawnAtPosition {
            board.promotePawn(atPosition: pawnPosition, promoteTo: type)
            canPromotePawnAtPosition = getPawnPromotePosition()
            if canPromotePawnAtPosition != nil {
                return
            }
            timer?.add(seconds: 3, for: turn)
            turn = turn.opposite
            updateStateAndTimer(game: self)

            guard history.count >= 1 else { return }
            history[history.count - 1].pawnPromotedTo = type
        }
    }

    private func updateStateAndTimer(game: ClassicGame) {
        state = game.getState()
        switch state {
        case .checkmate, .stalemate:
            timer?.stop()
        case .inProgress:
            break
        }
    }

    private func castle(game: ClassicGame, side: CastleSide, from: Position) {
        let rookPosition = Position(rawValue: from.rawValue + (side == .kingSide ? 3 : -4))!
        if let newRookPosition = Position(
            rawValue: side == .kingSide ? from.rawValue + 1 : from.rawValue - 1
        ) {
            game.board.movePiece(fromPosition: rookPosition, toPosition: newRookPosition)
        }

    }

    func undoLastMove() {
        guard let move = history.last else { return }

        if canPromotePawnAtPosition != nil {
            board.movePiece(fromPosition: move.to, toPosition: move.from)
            canPromotePawnAtPosition = nil

            if let capturedPiece = move.capturedPiece {
                board.addPiece(capturedPiece, atPosition: move.to)
            }
            history.removeLast()
            return
        }

        if move.pawnPromotedTo != nil {
            board.removePiece(atPosition: move.to)
            if let piece = move.piece {
                board.addPiece(piece, atPosition: move.to)
            }
        }

        board.movePiece(fromPosition: move.to, toPosition: move.from)

        if let capturedPiece = move.capturedPiece {
            if move.capturedByEnPassant {
                if let position = Position(
                    rawValue: move.to.rawValue - (turn.opposite == .white ? 8 : -8)
                ) {
                    board.addPiece(capturedPiece, atPosition: position)
                }
            } else {
                board.addPiece(capturedPiece, atPosition: move.to)
            }
        } else if let castleSide = move.castling {
            let rookPosition = Position(
                rawValue: move.to.x * 8 + (castleSide == .kingSide ? 5 : 3)
            )!
            let newRookPosition = Position(
                rawValue: move.to.x * 8 + (castleSide == .kingSide ? 7 : 0)
            )!

            board.movePiece(fromPosition: rookPosition, toPosition: newRookPosition)
        }

        history.removeLast()
        canPromotePawnAtPosition = nil
        turn = turn.opposite
        state = getState()
        timer?.set(seconds: move.timeLeft ?? 0, for: turn)
        timer?.start()
    }

    private func isEnPassantAllowed(fromPosition from: Position, toPosition to: Position) -> Bool {
        guard let piece = board[from],
              piece.type == .pawn,
              let lastMove = history.last,
              abs(lastMove.to.rawValue - lastMove.from.rawValue) == 16,
              let otherPiece = board[lastMove.to],
              otherPiece.type == .pawn,
              piece.color != otherPiece.color,
              abs(to.x - from.x) == 1 else { return false }

        switch piece.color {
        case .white:
            return lastMove.to.x == to.x - 1 && lastMove.to.y == to.y
        case .black:
            return lastMove.to.x == to.x + 1 && lastMove.to.y == to.y
        }
    }

    private func piecesExistBetween(fromPosition from: Position, toPosition to: Position) -> Bool {
        let stepX = from.x < to.x ? 1 : (from.x > to.x ? -1 : 0)
        let stepY = from.y < to.y ? 1 : (from.y > to.y ? -1 : 0)

        var positionX = from.x
        var positionY = from.y

        positionX += stepX
        positionY += stepY

        while positionX != to.x || positionY != to.y {
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

        guard from.y == 4, [2, 6].contains(to.y),
              from.x == to.x,
              !pieceHasMoved(atPosition: from),
              !piecesExistBetween(fromPosition: from, toPosition: to) else { return false }

        if piece.color == .white {
            if piecesExistBetween(fromPosition: from, toPosition: to.y == 6 ? .h1 : .a1) ||
                from.x != 0 || to.x != 0 { return false }

            if !pieceHasMoved(atPosition: Position(rawValue: to.y == 6 ? 7 : 0)!) {
                let positions: [Position] = to.y == 6 ? [.e1, .f1, .g1] : [.c1, .d1, .e1]
                return !positions.contains(where: { isPositionThreatened($0, byColor: .black) })
            }
        } else {
            if piecesExistBetween(fromPosition: from, toPosition: to.y == 6 ? .h8 : .a8) ||
                from.x != 7 || to.x != 7 { return false }

            if !pieceHasMoved(atPosition: Position(rawValue: to.y == 6 ? 63 : 56)!) {
                let positions: [Position] = to.y == 6 ? [.e8, .f8, .g8] : [.c8, .d8, .e8]
                return !positions.contains(where: { isPositionThreatened($0, byColor: .white) })
            }
        }
        return false
    }

    private func isPositionThreatened(_ position: Position?, byColor color: PieceColor) -> Bool {
        guard let position = position else { return false }

        return Position.allCases.contains { from in
            if let piece = board[from] {
                guard piece.color == color else { return false }

                if piece.type == .pawn {
                    let deltaX = position.x - from.x
                    let deltaY = position.y - from.y

                    switch piece.color {
                    case .white:
                        return deltaX == 1 && [-1, 1].contains(deltaY) &&
                            position.x == from.x + 1
                    case .black:
                        return deltaX == -1 && [-1, 1].contains(deltaY) &&
                            position.x == from.x - 1
                    }
                } else {
                    return canMove(fromPosition: from, toPosition: position)
                }
            }
            return false
        }
    }

    func isKingInCheck(forColor color: PieceColor) -> Bool {
        return isPositionThreatened(getKingPosition(forColor: color), byColor: color.opposite)
    }

    private func getKingPosition(forColor color: PieceColor) -> Position? {
        return Position.allCases.first { position in
            if let piece = board[position] {
                if piece.color == color, piece.type == .king {
                    return true
                }
            }
            return false
        }
    }

    func allMoves(fromPosition position: Position) -> [Position] {
        guard let piece = board[position] else { return [] }

        return Position.allCases.filter {
            if canMove(fromPosition: position, toPosition: $0) {
                let newGame = ClassicGame(board: board)
                newGame.board.movePiece(fromPosition: position, toPosition: $0)
                return !newGame.isKingInCheck(forColor: piece.color)
            }
            return false
        }
    }

    func allMoves(for color: PieceColor) -> [Move] {
        var moves = [Move]()

        Position.allCases.forEach { from in
            if let piece = board[from],
               piece.color == color {
                allMoves(fromPosition: from).forEach { to in
                    if canMove(fromPosition: from, toPosition: to) {
                        let newGame = ClassicGame(board: board)
                        newGame.board.movePiece(fromPosition: from, toPosition: to)
                        if !newGame.isKingInCheck(forColor: piece.color) {
                            moves.append(Move(from: from, to: to, piece: piece))
                        }
                    }
                }
            }
        }

        return moves
    }
}

extension ClassicGame {

    func didUpdateTime(with time: Int, for color: PieceColor) {
        guard whiteTime != nil, blackTime != nil else { return }

        switch color {
        case .white:
            if time / 10 != whiteTime! {
                whiteTime = time / 10
            }
        case .black:
            if time / 10 != blackTime! {
                blackTime = time / 10
            }
        }

        delegate?.didUpdateTime(with: time, for: color)
    }

}
