//
//  PuzzleGame.swift
//  Chessy
//
//  Created by Yasha Serhiienko on 02.08.2023.
//

final class PuzzleGame: ClassicGame {

    let solution: [Move]

    init(with puzzle: Puzzle) {
        self.solution = puzzle.moves

        super.init(fromFen: puzzle.fen)
    }

    override func movePiece(fromPosition from: Position, toPosition to: Position) {
        super.movePiece(fromPosition: from, toPosition: to)
    }

}
