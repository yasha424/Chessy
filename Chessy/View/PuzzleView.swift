//
//  PuzzleView.swift
//  Chessy
//
//  Created by Yasha Serhiienko on 01.08.2023.
//

import SwiftUI

struct PuzzleView: View {

    @ObservedObject private var puzzleVM: PuzzleViewModel
    private let boardView: BoardView<PuzzleViewModel>

    init(puzzleVM: PuzzleViewModel) {
        self.puzzleVM = puzzleVM
        self.boardView = BoardView(vm: puzzleVM, shouldRotate: .constant(false))
    }

    var body: some View {
        HStack {
            Spacer()
            VStack {
                Spacer()
                boardView
                    .padding(8)
                    .onAppear(perform: puzzleVM.firstMove)
                    .onChange(of: puzzleVM.puzzle) { _ in
                        puzzleVM.firstMove()
                    }
                    .overlay {
                        if puzzleVM.solved {
                            Text("Puzzle solved. Great job!")
                                .padding()
                                .glassView()
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .background(Color.black.opacity(0.3))
                                .padding(18)
                        }
                    }
                Spacer()
            }
            Spacer()
        }
        .customBackground()
    }
}
