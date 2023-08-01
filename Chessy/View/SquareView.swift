//
//  SquareView.swift
//  Chessy
//
//  Created by Yasha Serhiienko on 18.07.2023.
//

import SwiftUI

struct SquareView<ChessGame: Game>: View {

    @ObservedObject var gameVM: GameViewModel<ChessGame>
    let position: Position

    @State private var tapOffset = CGSize.zero
    @State private var size: CGSize!
    @State private var isDragged: Bool = false
    @State private var gestureLocation: CGPoint = CGPoint.zero

    @State private var changes = 0
    private let refreshRate = 3

    @Environment(\.shouldRotate) var shouldRotate
    @Environment(\.horizontalSizeClass) var sizeClass

    var dragGesture: some Gesture {
        DragGesture()
            .onChanged { gesture in
                if gameVM.canSelectPiece(atPosition: position) {
                    if gameVM.selectedPosition != position || !isDragged {
                        isDragged = true
                        gameVM.selectPosition(position)
                        gameVM.selectedRow = 7 - position.x
                    }

                    if shouldRotate && gameVM.turn == .black {
                        gestureLocation = CGPoint(
                            x: -gesture.location.x + size.width,
                            y: -(gesture.location.y - size.height)
                        )
                    } else {
                        gestureLocation = CGPoint(
                            x: gesture.location.x,
                            y: (gesture.location.y - size.height)
                        )
                    }

                    if changes % refreshRate == 0 {
                        gameVM.computeDraggedPosition(location: gesture.location, size: size)
                    }
                    changes += 1
                }
            }
            .onEnded { _ in
                isDragged = false

                withAnimation(.spring(response: 0.3)) {
                    gestureLocation = CGPoint(x: size.width / 2, y: size.height / 2)
                }

                gameVM.deselectPosition()
                gameVM.selectedRow = nil

                if let to = gameVM.draggedTo {
                    gameVM.movePiece(fromPosition: position, toPosition: to)
                }
                gameVM.draggedTo = nil
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

                if [gameVM.lastMove?.from,
                    gameVM.lastMove?.to].contains(position) {
                    Color.green.opacity(0.25)
                }

                if gameVM.draggedTo == position {
                    Circle()
                        .foregroundColor(.green)
                        .opacity(0.5)
                        .scaleEffect(x: 1.8, y: 1.8)
                }

                if let piece = gameVM.getPiece(atPosition: position) {

                    if piece.type == .king && gameVM.isKingInCheck(forColor: piece.color) {
                        Circle()
                            .blur(radius: 15)
                            .foregroundColor(.red)
                            .scaleEffect(CGSize(width: 0.7, height: 0.7))
                    }

                    if isDragged {
                        Image(ImageNames.color[piece.color]! + ImageNames.type[piece.type]!)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .padding(geometry.size.width / 8)
                            .rotationEffect(Angle(
                                degrees: shouldRotate && gameVM.turn == .black ? 180 : 0
                            ))
                            .opacity(0.3)
                    }

                    Image(ImageNames.color[piece.color]! + ImageNames.type[piece.type]!)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .padding(geometry.size.width / 8)
                        .scaleEffect(x: isDragged ? 2 : 1, y: isDragged ? 2 : 1)
                        .shadow(
                            color: Color.green,
                            radius: gameVM.selectedPosition == position ? 5 : 0
                        )
                        .position(gestureLocation)
                        .rotationEffect(Angle(
                            degrees: shouldRotate && gameVM.turn == .black ? 180 : 0
                        ))
                        .offset(tapOffset)
                        .onAppear {
                            performAnimation(withSize: geometry.size)
                        }
                        .onChange(of: gameVM.animatedMove) { _ in
                            performAnimation(withSize: geometry.size)
                        }
                        .animation(.spring(response: 0.1), value: isDragged)
                }

                if gameVM.allowedMoves.contains(position) {
                    Circle()
                        .foregroundColor(.green)
                        .opacity(0.9)
                        .scaleEffect(CGSize(width: 0.2, height: 0.2))
                }
            }
            .gesture(dragGesture)
            .onChange(of: geometry.size) { _ in
                size = geometry.size
                gestureLocation = CGPoint(x: size.width / 2, y: size.height / 2)
            }
            .onAppear {
                size = geometry.size
                gestureLocation = CGPoint(x: size.width / 2, y: size.height / 2)
            }
        }
    }

    private func performAnimation(withSize size: CGSize) {
        if let move = gameVM.animatedMove,
           move.to == position {
            let deltaX = position.x - move.from.x
            let deltaY = position.y - move.from.y
            tapOffset = CGSize(
                width: size.width * CGFloat(-deltaY),
                height: size.height * CGFloat(deltaX)
            )
            withAnimation(.spring(response: 0.3)) {
                tapOffset.width = 0
                tapOffset.height = 0
            }
        } else {
            tapOffset = CGSize.zero
        }
    }

    func getOffset() -> CGSize {
        if let lastMove = gameVM.lastMove,
           lastMove.to == position {
            let deltaX = position.x - lastMove.from.x
            let deltaY = position.y - lastMove.from.y

            return CGSize(width: deltaX, height: deltaY)
        }
        return CGSize.zero
    }

}
