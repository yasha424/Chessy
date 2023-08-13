//
//  PuzzleViewModel.swift
//  Chessy
//
//  Created by Yasha Serhiienko on 01.08.2023.
//

import Combine

class PuzzleViewModel<ChessGame: Game>: ObservableObject {

    func getPuzzle() -> Puzzle {
        return Puzzle(
            id: "00sHx",
            fen: "q3k1nr/1pp1nQpp/3p4/1P2p3/4P3/B1PP1b2/B5PP/5K2 b k - 0 17",
            moves: [
                Move(fromString: "e8d7"),
                Move(fromString: "a2e6"),
                Move(fromString: "d7d8"),
                Move(fromString: "f7f8")
            ],
            rating: 1760
        )
    }

}
