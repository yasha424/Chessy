//
//  PuzzleGame.swift
//  Chessy
//
//  Created by Yasha Serhiienko on 02.08.2023.
//

final class PuzzleGame: ClassicGame {

    private let solution: [Move]
    private(set) var selectedPosition: Position?
    private(set) var allowedMoves = [Position]()

    init(with puzzle: Puzzle) {
        self.solution = puzzle.moves

        super.init(fromFen: puzzle.fen)
    }

    override func movePiece(fromPosition from: Position, toPosition to: Position) {
        super.movePiece(fromPosition: from, toPosition: to)
    }

    func selectPosition(_ position: Position) {
        self.selectedPosition = position
        self.allowedMoves = allMoves(fromPosition: position)
    }

    func deselectPosition() {
        self.selectedPosition = nil
        self.allowedMoves = []
    }
}
