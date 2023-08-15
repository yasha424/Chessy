//
//  PuzzleView.swift
//  Chessy
//
//  Created by Yasha Serhiienko on 01.08.2023.
//

import SwiftUI

struct PuzzleView: View {

    @StateObject var puzzleVM = PuzzleViewModel<ClassicGame>()

    @State private var isDragged: Bool = false
    @State private var gestureLocation: CGPoint = CGPoint.zero

    //    var dragGesture: some Gesture {
    //        DragGesture()
    //            .onChanged { gesture in
    //                if gameVM.canSelectPiece(atPosition: position) {
    //                    if gameVM.selectedPosition != position || !isDragged {
    //                        isDragged = true
    //                        gameVM.selectPosition(position)
    //                        gameVM.selectedRow = 7 - position.x
    //                    }
    //
    ////                    if shouldRotate && gameVM.turn == .black {
    ////                        gestureLocation = CGPoint(
    ////                            x: -gesture.location.x + size.width,
    ////                            y: -(gesture.location.y - size.height)
    ////                        )
    ////                    } else {
    //                        gestureLocation = CGPoint(
    //                            x: gesture.location.x,
    //                            y: (gesture.location.y - size.height)
    //                        )
    ////                    }
    //
    //                    if changes % refreshRate == 0 {
    //                        gameVM.computeDraggedPosition(location: gesture.location, size: size)
    //                    }
    //                    changes += 1
    //                }
    //            }
    //            .onEnded { _ in
    //                isDragged = false
    //
    //                withAnimation(.spring(response: 0.3)) {
    //                    gestureLocation = CGPoint(x: size.width / 2, y: size.height / 2)
    //                }
    //
    //                gameVM.deselectPosition()
    //                gameVM.selectedRow = nil
    //
    //                if let to = gameVM.draggedTo {
    //                    gameVM.movePiece(fromPosition: position, toPosition: to)
    //                }
    //                gameVM.draggedTo = nil
    //            }
    //    }

    var body: some View {

        let puzzleGame = PuzzleGame(with: puzzleVM.getPuzzle())

        VStack(spacing: 0) {
            ForEach(0..<8) { i in
                HStack(spacing: 0) {
                    ForEach(0..<8) { j in
                        let position = Position(rawValue: (7 - i) * 8 + j)!

                        GeometryReader { geometry in
                            ZStack {
                                if position.x % 2 == position.y % 2 {
                                    Colors.whiteSquare
                                        .opacity(0.3)
                                } else {
                                    Colors.blackSquare
                                        .opacity(0.3)
                                }

                                if let piece = puzzleGame.board[position] {

                                    if piece.type == .king &&
                                       puzzleGame.isKingInCheck(forColor: piece.color) {
                                        Circle()
                                            .blur(radius: 15)
                                            .foregroundColor(.red)
                                            .scaleEffect(CGSize(width: 0.7, height: 0.7))
                                    }

                                    Image(ImageNames.color[piece.color]! +
                                          ImageNames.type[piece.type]!)
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .padding(geometry.size.width / 8)
                                        .scaleEffect(x: isDragged ? 2 : 1, y: isDragged ? 2 : 1)
                                        .shadow(
                                            color: Color.green,
                                            radius: puzzleGame.selectedPosition == position ? 5 : 0
                                        )
                                        .position(gestureLocation)
                                }
                            }
                            .gesture(
                                DragGesture()
                                    .onChanged { gesture in
                                        if puzzleGame.canSelectPiece(atPosition: position) {
                                            if puzzleGame.selectedPosition != position ||
                                               !isDragged {
                                                isDragged = true
                                                puzzleGame.selectPosition(position)
                                            }

                                            gestureLocation = CGPoint(
                                                x: gesture.location.x,
                                                y: (gesture.location.y - geometry.size.height)
                                            )
                                        }
                                    }
                                    .onEnded { _ in
                                        isDragged = false

                                        withAnimation(.spring(response: 0.3)) {
                                            gestureLocation = CGPoint(
                                                x: geometry.size.width / 2,
                                                y: geometry.size.height / 2
                                            )
                                        }

                                            puzzleGame.deselectPosition()
                                    }
                            )
                        }
                    }
                }
            }
        }
        .aspectRatio(1, contentMode: .fit)
    }
}
