//
//  BoardView.swift
//  Chessy
//
//  Created by Yasha Serhiienko on 09.07.2023.
//

import SwiftUI

struct BoardView: View {
    
    @ObservedObject var board: Board
    @State var tapAtPosition: Position? = nil
    @State var allowedMoves = [Position]()
    
    var body: some View {
        let color = [PieceColor.white: "white_", PieceColor.black: "black_"]
        let type: [PieceType: String] = [
            .pawn: "pawn",
            .knight: "knight",
            .bishop: "bishop",
            .rook: "rook",
            .queen: "queen",
            .king: "king"
        ]
        
        VStack(spacing: 0) {
            ForEach(0..<8) { i in
                HStack(spacing: 0) {
                    ForEach(0..<8) { j in
                        let position = Position(rawValue: (7 - i) * 8 + j)!
                            ZStack {
                                if i % 2 == j % 2 {
                                    Colors.whiteSquare
                                } else {
                                    Colors.blackSquare
                                }
                                
                                if let lastMove = board.history.last {
                                    if [lastMove.from, lastMove.to].contains(position) {
                                        Color.init(red: 0.3, green: 1.0, blue: 0.3, opacity: 0.3)
                                    }
                                }
                                
                                if let piece = board[position] {
                                    let canSelectPiece = tapAtPosition == position &&
                                    board.canSelectPiece(atPosition: position)
                                    Image("\(color[piece.color]! + type[piece.type]!)")
                                        .resizable()
                                        .shadow(
                                            color: Color.green,
                                            radius: canSelectPiece ? 3 : 0
                                        )
                                }
                                if allowedMoves.contains(position) {
//                                    GeometryReader { geometry in
                                        Image(systemName: "circle.fill")
                                            .foregroundColor(Color.green)
                                            .opacity(0.7)
//                                            .frame(
//                                                width: geometry.size.width * 4,
//                                                height: geometry.size.height * 4
//                                            )
//                                    }
                                }
                            }
                            .onTapGesture {
                                if tapAtPosition == nil {
                                    tapAtPosition =
                                    board.canSelectPiece(atPosition: position) ? position : nil
                                } else if tapAtPosition == position {
                                    tapAtPosition = nil
                                } else if board.canSelectPiece(atPosition: position) {
                                    tapAtPosition = position
                                } else {
                                    board.movePiece(fromPosition: tapAtPosition!, toPosition: position)
                                    tapAtPosition = nil
                                }
                                if tapAtPosition != nil {
                                    allowedMoves = board.allMoves(fromPosition: position)
                                } else {
                                    allowedMoves = []
                                }
                            }
                            .aspectRatio(1, contentMode: .fit)
                    }
                }
            }
        }
        .border(.black)
    }
}
