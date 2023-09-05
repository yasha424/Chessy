//
//  PuzzleListView.swift
//  Chessy
//
//  Created by Yasha Serhiienko on 01.08.2023.
//

import SwiftUI

struct PuzzleListView: View {

    @State private var puzzleVMs = [PuzzleViewModel]()
    @State private var selectedPuzzleId: String?
    @State private var puzzleIndex = 1

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
                Color.clear
                    .listRowBackground(Color.clear)
                    .task {
                        let newPuzzles = await PuzzleDataSource.instance.getPuzzles(
                            from: puzzleIndex,
                            to: puzzleIndex + 10
                        )
                        puzzleIndex += 10
                        puzzleVMs.append(contentsOf: newPuzzles.map { PuzzleViewModel(puzzle: $0) })
                    }
            }
            .hideBackground()
            .customBackground()
            .navigationTitle("Puzzles")
        }
        .refreshable {
            puzzleIndex = 1
            puzzleVMs = await PuzzleDataSource.instance.getPuzzles(
                from: puzzleIndex,
                to: puzzleIndex + 10
            ).map { PuzzleViewModel(puzzle: $0) }
            puzzleIndex += 10
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

struct PuzzleListViewPreview: PreviewProvider {
    static var previews: some View {
        PuzzleListView()
    }
}
