//
//  PuzzleListViewItem.swift
//  Chessy
//
//  Created by Yasha Serhiienko on 01.08.2023.
//

import SwiftUI

struct PuzzleListViewItem: View {

    @ObservedObject var puzzleVM: PuzzleViewModel

    var body: some View {
        HStack {
            BoardPreview(board: puzzleVM.game.board)
                .frame(minWidth: 100, maxWidth: 200)
                .padding(8)
            Spacer()
            VStack {
                HStack {
                    Text("Rating:")
                    Text("\(puzzleVM.puzzle.rating)")
                }
                Spacer()
            }
            .padding(8)
        }
        .glassView()
    }
}
