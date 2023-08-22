//
//  SquareView.swift
//  Chessy
//
//  Created by Yasha Serhiienko on 18.07.2023.
//

import SwiftUI

struct SquareView<ViewModel: ViewModelProtocol>: View {

    @ObservedObject var vm: ViewModel
    let piece: Piece?
    let position: Position

    @State private var tapOffset = CGSize.zero
    @State private var size: CGSize!
    @State private var isDragged: Bool = false
    @State private var gestureLocation: CGPoint = CGPoint.zero

    @State private var changes = 0
    private let refreshRate = 3

    @AppStorage("shouldRotate") var shouldRotate: Bool = false

    var dragGesture: some Gesture {
        DragGesture()
            .onChanged { gesture in
                DispatchQueue.global(qos: .userInteractive).async {
                    updateGesture(with: gesture)
                }
            }
            .onEnded { _ in
                DispatchQueue.global(qos: .userInteractive).async {
                    endGesture()
                }
            }
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                if position.x % 2 == position.y % 2 {
                    Colors.whiteSquare.opacity(0.3)
                } else {
                    Colors.blackSquare.opacity(0.3)
                }

                if position.y == 0 {
                    HStack {
                        VStack {
                            Text(position.rank)
                                .minimumScaleFactor(0.2)
                                .font(.system(size: 10))
                                .opacity(0.7)
                                .padding(.leading, 2)
                            Spacer()
                        }
                        Spacer()
                    }
                }
                if position.x == 0 {
                    HStack {
                        Spacer()
                        VStack {
                            Spacer()
                            Text(position.file)
                                .minimumScaleFactor(0.2)
                                .font(.system(size: 10))
                                .opacity(0.7)
                                .padding([.bottom, .trailing], 1)
                        }
                    }
                }

                if [vm.lastMove?.from, vm.lastMove?.to].contains(position) {
                    Color.green.opacity(0.25)
                }

                if vm.draggedTo == position {
                    Circle()
                        .foregroundColor(.green)
                        .opacity(0.3)
                        .scaleEffect(x: 1.9, y: 1.9)
                }

                if let piece = self.piece {
                    if piece.type == .king && vm.kingInCheckForColor == piece.color {
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
                                degrees: shouldRotate && vm.turn == .black ? 180 : 0
                            ))
                            .opacity(0.2)
                    }

                    Image(ImageNames.color[piece.color]! + ImageNames.type[piece.type]!)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .padding(geometry.size.width / 8)
                        .scaleEffect(x: isDragged ? 2 : 1, y: isDragged ? 2 : 1)
                        .shadow(
                            color: .green,
                            radius: vm.selectedPosition == position ? 5 : 0
                        )
                        .position(gestureLocation)
                        .rotationEffect(Angle(
                            degrees: shouldRotate && vm.turn == .black ? 180 : 0
                        ))
                        .offset(tapOffset)
                        .onAppear {
                            performAnimation(withSize: geometry.size)
                        }
                        .onChange(of: vm.animatedMoves) { _ in
                            performAnimation(withSize: geometry.size)
                        }
                        .animation(.spring(response: 0.1), value: isDragged)
                }

                if vm.allowedMoves.contains(position) {
                    if piece != nil {
                        CapturePieceShape()
                            .stroke(.red, style: StrokeStyle(lineWidth: 2, lineJoin: .miter))
                            .padding(1)
                            .opacity(0.8)
                    } else {
                        Circle()
                            .foregroundStyle(.green)
                            .opacity(0.8)
                            .scaleEffect(CGSize(width: 0.2, height: 0.2))
                    }
                }
            }
            .aspectRatio(1, contentMode: .fit)
            .onTapGesture {
                DispatchQueue.global(qos: .userInteractive).async {
                    vm.selectPosition(position)
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
            .accessibilityElement()
            .accessibilityLabel(Text("" + "\(position)"))
        }
    }

    private func performAnimation(withSize size: CGSize) {
        for move in vm.animatedMoves {
            if move.to == position {
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
    }

    func getOffset() -> CGSize {
        if let lastMove = vm.lastMove,
           lastMove.to == position {
            let deltaX = position.x - lastMove.from.x
            let deltaY = position.y - lastMove.from.y

            return CGSize(width: deltaX, height: deltaY)
        }
        return CGSize.zero
    }

    private func updateGesture(with gesture: DragGesture.Value) {
        if vm.canSelectPiece(atPosition: position) {
            if vm.selectedPosition != position || !isDragged {
                DispatchQueue.main.async {
                    isDragged = true
                }
                vm.selectPosition(position)
            }

            if shouldRotate && vm.turn == .black {
                DispatchQueue.main.async {
                    withAnimation(.spring(response: 0.1)) {
                        gestureLocation = CGPoint(
                            x: -gesture.location.x + size.width,
                            y: -(gesture.location.y - size.height)
                        )
                    }
                }
            } else {
                DispatchQueue.main.async {
                    withAnimation(.spring(response: 0.1)) {
                        gestureLocation = CGPoint(
                            x: gesture.location.x,
                            y: (gesture.location.y - size.height)
                        )
                    }
                }
            }

            DispatchQueue.global(qos: .background).async {
                if changes % refreshRate == 0 {
                    vm.computeDraggedPosition(
                        location: gesture.location,
                        size: size
                    )
                }
                changes += 1
            }
        }
    }

    private func endGesture() {
        DispatchQueue.main.async {
            isDragged = false

            withAnimation(.spring(response: 0.3)) {
                gestureLocation = CGPoint(x: size.width / 2, y: size.height / 2)
            }
            if let to = vm.draggedTo {
                vm.movePiece(fromPosition: position, toPosition: to, isAnimated: false)
            }
        }
        vm.deselectPosition()

        vm.endedGesture()
    }

}
