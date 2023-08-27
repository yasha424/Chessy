//
//  PuzzleListView.swift
//  Chessy
//
//  Created by Yasha Serhiienko on 01.08.2023.
//

import SwiftUI

struct PuzzleListView: View {

    @State private var puzzleVMs = [
        PuzzleViewModel(puzzle: Puzzle(
            id: UUID().uuidString,
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
        )),
        PuzzleViewModel(puzzle: Puzzle(
            id: UUID().uuidString,
            fen: "q3k1nr/1pp1nQpp/3p4/1P2p3/4P3/B1PP1b2/B5PP/5K2 b k - 0 17",
            moves: [
                Move(fromString: "e8d7"),
                Move(fromString: "a2e6"),
                Move(fromString: "d7d8"),
                Move(fromString: "f7f8")
            ],
            rating: 1760
        )),
        PuzzleViewModel(puzzle: Puzzle(
            id: UUID().uuidString,
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
        ))
    ]
    @State private var selectedPuzzleId: String?

    var body: some View {
        NavigationView {
            List(selection: $selectedPuzzleId) {
                ForEach(puzzleVMs, id: \.puzzle.id) { vm in
                    let puzzleView = PuzzleView(puzzleVM: vm)

                    ZStack {
                        NavigationLink {
                            puzzleView
                                .onDisappear {
                                    selectedPuzzleId = nil
                                }
                        } label: {
                            EmptyView()
                        }
                        PuzzleListViewItem(puzzleVM: vm)
                    }
                    .listRowBackground(
                        Color.gray
                            .cornerRadius(14)
                            .opacity(selectedPuzzleId == vm.puzzle.id ? 0.2 : 0)
                    )
                    .listRowInsets(EdgeInsets())
                    .listRowSeparator(.hidden)
                    .swipeActions(allowsFullSwipe: false) {
                        Button(role: .destructive) {
                            puzzleVMs.removeAll(where: { $0.puzzle.id == vm.puzzle.id })
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                        .tint(.red)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical)
                }
                .onMove { from, to in
                    puzzleVMs.move(fromOffsets: from, toOffset: to)
                }
            }
            .hideBackground()
            .customBackground()
            .navigationTitle("Puzzles")
        }
        .refreshable {
            let puzzles = puzzleVMs.map { return $0.puzzle }
            puzzleVMs = []
            try? await Task.sleep(nanoseconds: 500_000_000)
            puzzleVMs = puzzles.map { PuzzleViewModel(puzzle: $0) }
        }
    }
}

extension View {
    func hideBackground() -> some View {
        if #available(iOS 16.0, *) {
            return self.scrollContentBackground(.hidden)
        } else {
            return self
        }
    }
}
