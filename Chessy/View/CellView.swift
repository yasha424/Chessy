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
    @State var isDragged: Bool = false
    
    @State var changes = 0
    let refreshRate = 3

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
                    if selectedPosition != position || !isDragged {
                        selectedPosition = position
                        allowedMoves = game.allMoves(fromPosition: position)
                        selectedRow = i
                        isDragged = true
                    }
                    offset = gesture.translation

                    Thread {
                        if changes % refreshRate == 0 {
                            draggedTo = computeDraggedPosition(offset: offset, size: size)
                        }
                        changes += 1
                    }.start()
                }
            }
            .onEnded { _ in
                allowedMoves = []
                selectedRow = nil
                
                withAnimation(.linear(duration: 0.3)) {
                    offset = CGSize.zero
                    selectedPosition = nil
                    isDragged = false
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
                        .opacity(0.3)
                } else {
                    Colors.blackSquare
                        .opacity(0.3)
                }
                
                if [game.history.last?.from, game.history.last?.to].contains(position) {
                    Color.green.opacity(0.25)
                }
                
                if draggedTo == position {
                    Circle()
                        .foregroundColor(.green)
                        .opacity(0.3)
                        .scaleEffect(x: 1.8, y: 1.8)
                }
                
                if let piece = game.board[position] {
                    
                    if piece.type == .king && game.isKingInCheck(forColor: piece.color) {
                        Circle()
                            .blur(radius: 15)
                            .foregroundColor(.red)
                            .scaleEffect(CGSize(width: 0.7, height: 0.7))
                    }
                    
                    let newOffset = CGSize(
                        width: offset.width,
                        height: offset.height - geometry.size.height
                    )
                    
                    Image("\(ImageNames.color[piece.color]! + ImageNames.type[piece.type]!)")
                        .resizable()
                        .scaleEffect(x: piece.type == .pawn ? 0.6 : 0.7, y: 0.7)
                        .scaleEffect(x: isDragged ? 1.75 : 1, y: isDragged ? 1.75 : 1)
                        .shadow(
                            color: Color.green,
                            radius: selectedPosition == position ? 5 : 0
                        )
                        .offset(isDragged ? newOffset : CGSize.zero)
                        .gesture(dragGesture)
                        .rotationEffect(Angle(degrees: game.turn == .white ? 0 : 180))
                }
                
                if allowedMoves.contains(position) {
                    Circle()
                        .foregroundColor(.green)
                        .opacity(0.9)
                        .scaleEffect(CGSize(width: 0.2, height: 0.2))
                }
            }
            .onChange(of: geometry.size) { _ in
                size = geometry.size
            }
            .onAppear {
                size = geometry.size
            }
        }
    }
    
    private func computeDraggedPosition(offset: CGSize, size: CGSize) -> Position? {
        let deltaX = Int((offset.height / size.height).rounded())
        let deltaY = Int((offset.width / size.width).rounded())

        if game.turn == .white {
            return Position(rawValue: (7 - i - deltaX) * 8 + j + deltaY)
        } else {
            return Position(rawValue: (7 - i + deltaX) * 8 + j - deltaY)
        }
    }
    
}
