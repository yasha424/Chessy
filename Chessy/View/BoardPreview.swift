//
//  BoardPreview.swift
//  Chessy
//
//  Created by Yasha Serhiienko on 16.08.2023.
//

import SwiftUI

struct BoardPreview: View {

    let board: Board

    var body: some View {
            VStack(spacing: 0) {
                ForEach(0..<8) { i in
                    HStack(spacing: 0) {
                        ForEach(0..<8) { j in
                            let position = Position(rawValue: (7 - i) * 8 + j)!

                            ZStack {
                                if position.x % 2 == position.y % 2 {
                                    Colors.whiteSquare.opacity(0.3)
                                } else {
                                    Colors.blackSquare.opacity(0.3)
                                }

                                if let piece = board[position] {
                                    Image(ImageNames.color[piece.color]! +
                                          ImageNames.type[piece.type]!)
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .scaleEffect(x: 0.8, y: 0.8)
                                }
                            }
                        }
                    }
                }
            }
            .aspectRatio(1, contentMode: .fit)
            .padding(10)
            .glassView()
    }
}
