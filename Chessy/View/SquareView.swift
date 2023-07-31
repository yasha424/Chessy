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

    @State var selected = false

    @Environment(\.horizontalSizeClass) var sizeClass

    @State private var size: CGSize!
    @State var offset: CGSize = CGSize.zero
    @State var isDragged: Bool = false

    @State var tapOffset = CGSize.zero

    @State var changes = 0
    let refreshRate = 3

    var dragGesture: some Gesture {
        DragGesture()
            .onChanged { gesture in
                if gameVM.canSelectPiece(atPosition: position) {
                    if gameVM.selectedPosition != position || !isDragged {
                        gameVM.selectPosition(position)
                        gameVM.selectedRow = 7 - position.x
                        withAnimation(.linear(duration: 0.1)) {
                            isDragged = true
                        }
                    }

                    offset = gesture.translation

                    if changes % refreshRate == 0 {
                        gameVM.draggedTo = computeDraggedPosition(offset: offset, size: size)
                    }
                    changes += 1
                }
            }
            .onEnded { _ in
                withAnimation(.spring(response: 0.3)) {
                    offset = CGSize.zero
                    isDragged = false
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
                        .opacity(0.3)
                        .scaleEffect(x: 1.8, y: 1.8)
                }

                if let piece = gameVM.getPiece(atPosition: position) {

                    if piece.type == .king && gameVM.isKingInCheck(forColor: piece.color) {
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
                        .aspectRatio(contentMode: .fit)
                        .padding(geometry.size.width / 8)
                        .scaleEffect(x: isDragged ? 2 : 1, y: isDragged ? 2 : 1)
                        .shadow(
                            color: Color.green,
                            radius: gameVM.selectedPosition == position ? 5 : 0
                        )
                        .offset(isDragged ? newOffset : CGSize.zero)
                        .gesture(dragGesture)
                        .rotationEffect(Angle(
                            degrees: sizeClass == .compact || gameVM.turn == .white ? 0 : 180
                        ))
                        .offset(tapOffset)
                        .onAppear {
                            performAnimation(withSize: geometry.size)
                        }
                        .onChange(of: gameVM.animatedMove) { _ in
                            performAnimation(withSize: geometry.size)
                        }
                }

                if gameVM.allowedMoves.contains(position) {
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

    private func computeDraggedPosition(offset: CGSize, size: CGSize) -> Position? {
        let deltaX = Int((offset.height / size.height).rounded())
        let deltaY = Int((offset.width / size.width).rounded())

        if sizeClass == .compact || gameVM.turn == .white {
            return Position(rawValue: (position.x - deltaX) * 8 + position.y + deltaY)
        } else {
            return Position(rawValue: (position.x + deltaX) * 8 + position.y - deltaY)
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
