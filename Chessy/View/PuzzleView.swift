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
        VStack {
            Spacer()
            BoardView(vm: puzzleVM, shouldRotate: false)
                .padding(8)
                .onAppear(perform: puzzleVM.firstMove)
                .onChange(of: puzzleVM.puzzle) { _ in
                    puzzleVM.firstMove()
                }
            Spacer()
        }
        .customBackground()
    }
}
