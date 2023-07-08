//
//  BoardView.swift
//  Chessy
//
//  Created by Yasha Serhiienko on 09.07.2023.
//

import SwiftUI

struct BoardView: View {
    
    let board = Board()
    
    var body: some View {
        VStack(spacing: 0) {
            ForEach(0..<8) { i in
                HStack(spacing: 0) {
                    ForEach(0..<8) { j in
                        ZStack {
                            if i % 2 == j % 2 {
                                Color.gray.aspectRatio(1, contentMode: .fit)
                            } else {
                                Color.black.aspectRatio(1, contentMode: .fit)
                            }
                            
                            if let piece = board[7 - i, j] {
                                Text(piece.color.rawValue + piece.type.rawValue)
                            }
                        }.onTapGesture {
                            if let piece = board[7 - i, j] {
                                print(piece.color.rawValue + piece.type.rawValue)
                            }
                        }
                    }
                }
            }
        }
        .border(.green)
        
    }
}
