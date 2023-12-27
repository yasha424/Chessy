//
//  Puzzle.swift
//  Chessy
//
//  Created by Yasha Serhiienko on 02.08.2023.
//

struct Puzzle: Identifiable, Equatable {
    let id: String
    let fen: String
    let moves: [Move]
    var rating: Int
    var themes: [String] = []
}

struct PuzzleApi: Codable {
    let id: String
    let fen: String
    let moves: String
    let rating: Int
    let themes: String
}
