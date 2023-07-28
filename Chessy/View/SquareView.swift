//
//  SquareView.swift
//  Chessy
//
//  Created by Yasha Serhiienko on 18.07.2023.
//

import SwiftUI

struct SquareView<ChessGame: Game>: View {
    @ObservedObject var game: ChessGame
    @Binding var selectedPosition: Position?
    @Binding var allowedMoves: [Position]
    @Binding var selectedRow: Int?
    @Binding var draggedTo: Position?
    @State var selected = false
//    let i: Int
//    let j: Int

    @Environment(\.horizontalSizeClass) var sizeClass

    @State private var size: CGSize!
    @State var offset: CGSize = CGSize.zero
    @State var isDragged: Bool = false

    @State var tapOffset = CGSize.zero

    @State var changes = 0
    let refreshRate = 3

    let position: Position
//    var position: Position {
//        Position(rawValue: (7 - i) * 8 + j)!
//    }
//    var id: Int {
//        i * 8 + j
//    }

    var dragGesture: some Gesture {
        DragGesture()
            .onChanged { gesture in
                if game.canSelectPiece(atPosition: position) {
                    if selectedPosition != position || !isDragged {
                        selectedPosition = position
                        allowedMoves = game.allMoves(fromPosition: position)
                        selectedRow = position.x
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

                withAnimation(.spring(duration: 0.3)) {
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
                if position.x % 2 == position.y % 2 {
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

                    Image(ImageNames.color[piece.color]! + ImageNames.type[piece.type]!)
                        .resizable()
                        .scaleEffect(x: piece.type == .pawn ? 0.6 : 0.7, y: 0.7)
                        .scaleEffect(x: isDragged ? 1.75 : 1, y: isDragged ? 1.75 : 1)
                        .shadow(
                            color: Color.green,
                            radius: selectedPosition == position ? 5 : 0
                        )
                        .offset(isDragged ? newOffset : CGSize.zero)
                        .gesture(dragGesture)
                        .rotationEffect(Angle(
                            degrees: sizeClass == .compact || game.turn == .white ? 0 : 180
                        ))
                        .offset(tapOffset)
                        .onAppear {
                            performAnimation(withSize: geometry.size)
                        }
                        .onChange(of: game.history) { _ in
                            performAnimation(withSize: geometry.size)
                        }
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

    private func performAnimation(withSize size: CGSize) {
        if let lastMove = game.history.last,
           lastMove.to == position {
            let deltaX = position.x - lastMove.from.x
            let deltaY = position.y - lastMove.from.y
            tapOffset = CGSize(
                width: size.width * CGFloat(-deltaY),
                height: size.height * CGFloat(deltaX)
            )
            withAnimation(.spring(duration: 0.25)) {
                tapOffset.width = 0
                tapOffset.height = 0
            }
        } else {
            tapOffset = CGSize.zero
        }
    }

    private func computeDraggedPosition(offset: CGSize, size: CGSize) -> Position? {
        let deltaX = Int((offset.height / size.height).rounded())
        let deltaY = Int((offset.width / size.width).rounded())

        if sizeClass == .compact || game.turn == .white {
            return Position(rawValue: (7 - position.x - deltaX) * 8 + position.y + deltaY)
        } else {
            return Position(rawValue: (7 - position.x + deltaX) * 8 + position.y - deltaY)
        }
    }

    func getOffset() -> CGSize {
        if let lastMove = game.history.last,
           lastMove.to == position {
            let deltaX = position.x - lastMove.from.x
            let deltaY = position.y - lastMove.from.y

            return CGSize(width: deltaX, height: deltaY)
        }
        return CGSize.zero
    }

}
