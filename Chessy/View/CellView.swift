//
//  SquareView.swift
//  Chessy
//
//  Created by Yasha Serhiienko on 18.07.2023.
//

import SwiftUI

struct CellView<ChessGame>: View where ChessGame: Game {

    @ObservedObject var game: ChessGame
    @Binding var selectedPosition: Position?
    @Binding var allowedMoves: [Position]
    @Binding var selectedRow: Int?
    @Binding var draggedTo: Position?
    let i: Int
    let j: Int

    @State private var size: CGSize!
    @State var offset: CGSize = CGSize.zero
    
    @State var changes = 0
    let refreshRate = 4

    var position: Position {
        Position(rawValue: (7 - i) * 8 + j)!
    }
    var index: Int {
        i * 8 + j
    }
    
    var dragGesture: some Gesture {
        DragGesture()
            .onChanged { gesture in
                if game.canSelectPiece(atPosition: position) {
                    if selectedPosition != position {
                        selectedPosition = position
                        allowedMoves = game.allMoves(fromPosition: position)
                        selectedRow = i
                    }
                    offset = gesture.translation

                    Thread {
                        if changes % refreshRate == 0 {
                            draggedTo = getDraggedToPosition(offset: offset, size: size)
                        }
                        changes += 1
                    }.start()
                }
            }
            .onEnded { _ in
                selectedPosition = nil
                allowedMoves = []
                selectedRow = nil
                
                withAnimation(.linear(duration: 0.3)) {
                    offset = CGSize.zero
                }
                
                if let to = draggedTo {
                    game.movePiece(fromPosition: position, toPosition: to)
                }
                draggedTo = nil
            }
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                if i % 2 == j % 2 {
                    Colors.whiteSquare
                        .border(Color.green, width: draggedTo == position ? 3 : 0)
                } else {
                    Colors.blackSquare
                        .border(Color.green, width: draggedTo == position ? 3 : 0)
                }
                
                if let piece = game.board[position] {
                    Image("\(ImageNames.color[piece.color]! + ImageNames.type[piece.type]!)")
                        .resizable()
                        .shadow(
                            color: Color.green,
                            radius: selectedPosition == position ? 5 : 0
                        )
                        .shadow(
                            color: piece.type == .king ? Color.red : Color.clear,
                            radius: game.isKingInCheck(forColor: piece.color) ? 10 : 0
                        )
                        .offset(selectedPosition == position ? offset : CGSize.zero)
                        .gesture(dragGesture)
                } else {
                    Spacer()
                        .aspectRatio(1, contentMode: .fit)
                }
                
                if allowedMoves.contains(position) {
                    Image("green.circle")
                        .resizable()
//                        .opacity(0.9)
                        .aspectRatio(1, contentMode: .fill)
                }
            }
            .aspectRatio(1, contentMode: .fit)
            .onAppear {
                size = geometry.size
            }
        }
    }
    
    private func getDraggedToPosition(offset: CGSize, size: CGSize) -> Position? {
        let deltaX = offset.height / size.height
        let deltaY = offset.width / size.width

        return Position(
            rawValue: (7 - i - Int(deltaX.rounded())) * 8 + j + Int(deltaY.rounded())
        )
    }
    
}
