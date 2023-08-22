//
//  PuzzleView.swift
//  Chessy
//
//  Created by Yasha Serhiienko on 01.08.2023.
//

import SwiftUI

struct PuzzleView: View {

    @ObservedObject var puzzleVM: PuzzleViewModel

    var body: some View {
        HStack {
            Spacer()
            VStack {
                Spacer()
                BoardView(vm: puzzleVM, shouldRotate: false)
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
