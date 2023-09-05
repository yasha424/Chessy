//
//  PuzzleDataSource.swift
//  Chessy
//
//  Created by Yasha Serhiienko on 31.08.2023.
//

import Foundation

struct PuzzleDataSource {
    static let instance = PuzzleDataSource()
    let puzzleStrings: [String] = {
        if let url = Bundle.main.url(forResource: "puzzles", withExtension: "csv") {
            let content = try? String(contentsOf: url)
            return content?.split(separator: "\n").map { String($0) } ?? []
        }
        return []
    }()

    func getPuzzles(from: Int, to: Int) async -> [Puzzle] {
        guard from > 0, from < to else { return [] }
        var puzzles = [Puzzle]()

//        if let url = Bundle.main.url(forResource: "puzzles", withExtension: "csv") {
//            do {
//                let content = try String(contentsOf: url)
//                let puzzleStrings = content.split(separator: "\n")
                guard puzzleStrings.count >= to else { return puzzles }
                for idx in from..<to {
                    let splittedPuzzleString = puzzleStrings[idx].split(separator: ",")

                    let id = String(splittedPuzzleString[0])
                    let fen = String(splittedPuzzleString[1])
                    var moves = [Move]()
                    for move in splittedPuzzleString[2].split(separator: " ") {
                        moves.append(Move(fromString: String(move)))
                    }
                    let rating = Int(splittedPuzzleString[3]) ?? 0

                    puzzles.append(Puzzle(id: id, fen: fen, moves: moves, rating: rating))
                }
//            } catch {}
//        }

        return puzzles
    }
}
