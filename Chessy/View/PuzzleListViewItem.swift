//
//  PuzzleListViewItem.swift
//  Chessy
//
//  Created by Yasha Serhiienko on 01.08.2023.
//

import SwiftUI

struct PuzzleListViewItem: View {

    @ObservedObject private var puzzleVM: PuzzleViewModel
    private let boardPreview: BoardPreview

    init(puzzleVM: PuzzleViewModel) {
        self.puzzleVM = puzzleVM
        self.boardPreview = BoardPreview(board: puzzleVM.game.board)
    }

    var body: some View {
        HStack(spacing: 8) {
            boardPreview
                .frame(minWidth: 100, maxWidth: 150)
                .padding()
            VStack(spacing: 8) {
                HStack {
                    if puzzleVM.solved {
                        Image(systemName: "checkmark.circle")
                            .foregroundStyle(.green)
                            .opacity(0.8)
                    } else {
                        Image(systemName: "x.circle")
                            .foregroundStyle(.red)
                            .opacity(0.8)
                    }
                    Spacer()
                }
                .animation(.spring(response: 0.5), value: puzzleVM.solved)
                HStack {
                    Text("Rating:")
                    Text("\(puzzleVM.puzzle.rating)")
                    Spacer()
                }
                Spacer()
            }
            .padding(.vertical)
            Spacer()
        }
        .glassView()
    }
}
