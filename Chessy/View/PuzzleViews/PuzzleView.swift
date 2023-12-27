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
    @State private var solved: Bool = false
    @Environment(\.verticalSizeClass) private var sizeClass

    init(puzzleVM: PuzzleViewModel) {
        self.puzzleVM = puzzleVM
        self.boardView = BoardView(vm: puzzleVM, shouldRotate: .constant(false))
    }

    var body: some View {
        VStack {
            puzzleBoardView
            skipMoveButton
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .customBackground()
    }
}

extension PuzzleView {
    private var puzzleBoardView: some View {
        boardView
            .overlay {
                if solved {
                    Text("Puzzle solved. Great job!")
                        .padding()
                        .glassView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.secondary.opacity(0.2))
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }
            }
            .padding(8)
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    puzzleVM.firstMove()
                }
            }
            .onChange(of: puzzleVM.puzzle) { _ in
                puzzleVM.firstMove()
            }
            .onReceive(puzzleVM.solved) {
                self.solved = $0
            }
    }

    private var skipMoveButton: some View {
        Button {
            puzzleVM.skipMove()
        } label: {
            Text("View solution")
                .padding()
                .frame(height: 40)
                .glassView()
        }
    }
}
