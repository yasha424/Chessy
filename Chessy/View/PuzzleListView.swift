//
//  PuzzleListView.swift
//  Chessy
//
//  Created by Yasha Serhiienko on 01.08.2023.
//

import SwiftUI

struct PuzzleListView: View {

//    @EnvironmentObject var puzzleVM: PuzzleViewModel

    @State var puzzles = [
        Puzzle(
            id: "00sJ9",
            fen: "r3r1k1/p4ppp/2p2n2/1p6/3P1qb1/2NQR3/PPB2PP1/R1B3K1 w - - 5 18",
            moves: [
                Move(fromString: "e3g3"),
                Move(fromString: "e8e1"),
                Move(fromString: "g1h2"),
                Move(fromString: "e1c1"),
                Move(fromString: "a1c1"),
                Move(fromString: "f4h6"),
                Move(fromString: "h2g1"),
                Move(fromString: "h6c1")
            ],
            rating: 2671
        ),
        Puzzle(
            id: "00sHx",
            fen: "q3k1nr/1pp1nQpp/3p4/1P2p3/4P3/B1PP1b2/B5PP/5K2 b k - 0 17",
            moves: [
                Move(fromString: "e8d7"),
                Move(fromString: "a2e6"),
                Move(fromString: "d7d8"),
                Move(fromString: "f7f8")
            ],
            rating: 1760
        ),
        Puzzle(
            id: "00sJb",
            fen: "Q1b2r1k/p2np2p/5bp1/q7/5P2/4B3/PPP3PP/2KR1B1R w - - 1 17",
            moves: [
                Move(fromString: "d1d7"),
                Move(fromString: "a5e1"),
                Move(fromString: "d7d1"),
                Move(fromString: "e1e3"),
                Move(fromString: "c1b1"),
                Move(fromString: "e3b6")
            ],
            rating: 2235
        )
    ]

    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack {
                    ForEach(puzzles, id: \.id) { puzzle in
                        let vm = PuzzleViewModel(puzzle: puzzle)

                        NavigationLink {
                            PuzzleView(puzzleVM: vm)
                        } label: {
                            PuzzleListViewItem(puzzleVM: vm)
                                .disabled(true)
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical)
                    }
                }
            }
            .customBackground()
            .navigationTitle("Puzzles")
        }
        .refreshable {
            let newPuzzles = puzzles
            puzzles = []
            puzzles = newPuzzles
        }
    }
}
