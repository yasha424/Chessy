//
//  PuzzleDataSource.swift
//  Chessy
//
//  Created by Yasha Serhiienko on 31.08.2023.
//

import Foundation

struct PuzzleDataSource {
    static var instance = PuzzleDataSource()
    let puzzleStrings: [String] = {
        if let url = Bundle.main.url(forResource: "puzzles", withExtension: "csv") {
            let content = try? String(contentsOf: url)
            return content?.split(separator: "\n").map { String($0) } ?? []
        }
        return []
    }()
    var puzzles = [Puzzle]()

    func getPuzzles(_ email: String?) async -> [Puzzle] {
        if let url = URLs.getPuzzles {
            var request = URLRequest(url: url)
            print(url)
            request.httpMethod = "POST"
            if let email = email {
                do {
                    request.httpBody = try JSONSerialization.data(withJSONObject: ["email": email])
                } catch {
                    print(error.localizedDescription)
                }
            }
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("application/json", forHTTPHeaderField: "Accept")

            var data: Data
            var response: URLResponse

            do {
                (data, response) = try await URLSession.shared.data(for: request)
            } catch {
                return []
            }
            if let response = response as? HTTPURLResponse, response.statusCode == 200 {
                do {
                    let puzzles = try JSONDecoder().decode([PuzzleApi].self, from: data)
                    return puzzles.map {
                        let moves = $0.moves.split(separator: " ").map { Move(fromString: String($0)) }
                        let themes = $0.themes.split(separator: " ").map { String($0) }
                        return Puzzle(id: $0.id, fen: $0.fen, moves: moves, rating: $0.rating, themes: themes)
                    }
                } catch {
                    print(error.localizedDescription)
                    return []
                }
            } else {
                var error: RegisterError
                do {
                    error = try JSONDecoder().decode(RegisterError.self, from: data)
                } catch {
                    return []
                }
            }
        }
        
        return []
    }
    
    mutating func addPuzzle(_ puzzle: Puzzle, email: String) async -> Bool {
        let moves = puzzle.moves.reduce(into: "") { partialResult, move in
            partialResult += "\(move.from)\(move.to)" + (move.pawnPromotedTo == nil ? " " : "\(move.pawnPromotedTo!) ")
        }.dropLast(1)
        let puzzleApi = PuzzleApi(id: puzzle.id, fen: puzzle.fen, moves: String(moves), rating: puzzle.rating, themes: "")
        do {
            let puzzleData = try JSONEncoder().encode(puzzleApi)
            if let url = URLs.savePuzzle {
                var request = URLRequest(url: url)
                print(url)
                request.httpMethod = "POST"
                request.httpBody = try JSONEncoder().encode(SendCreatePuzzle(email: email, puzzle: puzzleApi))
                request.addValue("application/json", forHTTPHeaderField: "Content-Type")
                request.addValue("application/json", forHTTPHeaderField: "Accept")

                var data: Data
                var response: URLResponse

                do {
                    (data, response) = try await URLSession.shared.data(for: request)
                    if let response = response as? HTTPURLResponse, response.statusCode == 200 {
                        return true
                    } else {
                        return false
                    }
                } catch {
                    print(error.localizedDescription)
                    return false
                }
            }
        } catch {
            print(error.localizedDescription)
        }
        return false
    }
}

struct SendCreatePuzzle: Codable {
    let email: String
    let puzzle: PuzzleApi
}
