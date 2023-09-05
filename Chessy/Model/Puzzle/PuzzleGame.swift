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
        self.timer = nil
        self.blackTime = nil
        self.whiteTime = nil
    }

    required init(board: Board) {
        fatalError("init(board:) has not been implemented")
    }

    override func movePiece(fromPosition from: Position, toPosition to: Position) {
        super.movePiece(fromPosition: from, toPosition: to)
    }

}
