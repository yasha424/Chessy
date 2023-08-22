//
//  PuzzleGameTests.swift
//  ChessyTests
//
//  Created by Yasha Serhiienko on 22.08.2023.
//

import XCTest

final class PuzzleGameTests: XCTestCase {

    let puzzle = Puzzle(
        id: UUID().uuidString,
        fen: "q3k1nr/1pp1nQpp/3p4/1P2p3/4P3/B1PP1b2/B5PP/5K2 b k - 0 17",
        moves: [
            Move(fromString: "e8d7"),
            Move(fromString: "a2e6"),
            Move(fromString: "d7d8"),
            Move(fromString: "f7f8")
        ],
        rating: 1760
    )

    func testPuzzleSolved() async throws {
        let puzzleVM = PuzzleViewModel(puzzle: self.puzzle)
        XCTAssertFalse(puzzleVM.solved)
        puzzleVM.firstMove()

        puzzleVM.selectPosition(.a2)
        try await Task.sleep(nanoseconds: 600_000_000)
        puzzleVM.selectPosition(.e6)

        puzzleVM.selectPosition(.f7)
        try await Task.sleep(nanoseconds: 600_000_000)
        puzzleVM.selectPosition(.f8)

        try await Task.sleep(nanoseconds: 10_000_000)
        XCTAssertTrue(puzzleVM.solved)
    }

}
