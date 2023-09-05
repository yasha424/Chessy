//
//  SquareView.swift
//  Chessy
//
//  Created by Yasha Serhiienko on 18.07.2023.
//

import SwiftUI

struct SquareView<ViewModel: ViewModelProtocol>: View {

    @ObservedObject var vm: ViewModel
    let position: Position
    let shouldRotate: Bool
    let pieceImageNamespace: Namespace.ID

    @State private var piece: Piece?
    @State private var isKingInCheckHere: Bool = false
    @State private var turn: PieceColor = .white
    @State private var animationOffset = CGSize.zero
    @State private var isDragged: Bool = false
    @State private var gestureLocation: CGPoint = .zero
    @State private var draggedTo: Bool = false
    @State private var isSelected: Bool = false
    @State private var isMoveHereAllowed = false
    @State private var wasLastMoveHere = false

    @State private var changes = 0
    private let refreshRate = 3

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                backgroundView

                if position.y == 0 {
                    showRankView
                }

                if position.x == 0 {
                    showFileView
                }

                if wasLastMoveHere {
                    Color.green.opacity(0.25)
                }

                if draggedTo {
                    Circle()
                        .foregroundColor(.green)
                        .opacity(0.3)
                        .scaleEffect(x: 1.9, y: 1.9)
                }

                if let piece = piece {
                    PieceImageView<ViewModel>(
                        piece: piece,
                        isKingInCheckHere: isKingInCheckHere,
                        position: position,
                        turn: $turn,
                        pieceImageNamespace: pieceImageNamespace,
                        isDragged: $isDragged,
                        isSelected: $isSelected,
                        gestureLocation: $gestureLocation,
                        size: Binding(get: { return proxy.size }, set: { _ in }),
                        shouldRotate: shouldRotate
                    )
                }

                if isMoveHereAllowed {
                    allowedMoveView
                }
            }
            .aspectRatio(1, contentMode: .fit)
            .onTapGesture {
                DispatchQueue.global(qos: .userInteractive).async {
                    vm.selectPosition(position)
                }
            }
            .gesture(
                DragGesture()
                    .onChanged { gesture in
                        if piece != nil {
                            DispatchQueue.global(qos: .userInteractive).async {
                                updateGesture(with: gesture, size: proxy.size)
                            }
                        }
                    }
                    .onEnded { _ in
                        DispatchQueue.global(qos: .userInteractive).async {
                            endGesture(size: proxy.size)
                        }
                    }
            )
            .onChange(of: proxy.size) { _ in
                gestureLocation = CGPoint(x: proxy.size.width / 2, y: proxy.size.height / 2)
            }
            .onAppear {
                gestureLocation = CGPoint(x: proxy.size.width / 2, y: proxy.size.height / 2)
            }
            .accessibilityElement()
            .accessibilityLabel(Text("" + "\(position)"))
        }
        .onReceive(vm.draggedTo) {
            if draggedTo != ($0 == position) {
                draggedTo = $0 == position
            }
        }
        .onReceive(vm.selectedPosition) {
            if isSelected != ($0 == position) {
                isSelected = ($0 == position)
            }
        }
        .onReceive(vm.allowedMoves) {
            let isAllowed = $0.contains(position)
            if isMoveHereAllowed != isAllowed {
                isMoveHereAllowed = isAllowed
            }
        }
        .onReceive(vm.lastMove) { move in
            let wasLastMoveHere = [move?.from, move?.to].contains(position)
            if self.wasLastMoveHere != wasLastMoveHere {
                self.wasLastMoveHere = wasLastMoveHere
            }
        }
        .onReceive(vm.turn) {
            self.turn = $0
        }
        .onAppear {
            self.piece = vm.getPiece(atPosition: position)
            self.updateKingInCheckValue(vm.kingInCheckForColor.value)
            if let move = vm.lastMove.value {
                self.wasLastMoveHere = [move.from, move.to].contains(position)
            }
        }
        .onReceive(vm.turn) { _ in
            withAnimation(.spring(response: 0.3)) {
                self.piece = vm.getPiece(atPosition: position)
            }
        }
        .onReceive(vm.kingInCheckForColor) {
            updateKingInCheckValue($0)
        }
        .onReceive(vm.didUpdateGame) { _ in
            self.piece = nil
            withAnimation(.spring(response: 0.3)) {
                self.piece = vm.getPiece(atPosition: position)
            }
        }
    }

    private func updateKingInCheckValue(_ kingInCheckForColor: PieceColor?) {
        guard let piece = piece else {
            if self.isKingInCheckHere != false {
                self.isKingInCheckHere = false
            }
            return
        }
        if piece.type == .king {
            let kingInCheck = kingInCheckForColor == piece.color
            if self.isKingInCheckHere != kingInCheck {
                self.isKingInCheckHere = kingInCheck
            }
        } else {
            if self.isKingInCheckHere != false {
                self.isKingInCheckHere = false
            }
        }
    }

    private func updateGesture(with gesture: DragGesture.Value, size: CGSize) {
        if vm.canSelectPiece(atPosition: position) {
            if vm.selectedPosition.value != position || !isDragged {
                DispatchQueue.main.async {
                    isDragged = true
                }
                vm.selectPosition(position)
            }

            if shouldRotate && turn == .black {
                DispatchQueue.main.async {
                    gestureLocation = CGPoint(
                        x: -gesture.location.x + size.width,
                        y: -(gesture.location.y - size.height)
                    )
                }
            } else {
                DispatchQueue.main.async {
                    gestureLocation = CGPoint(
                        x: gesture.location.x,
                        y: (gesture.location.y - size.height)
                    )
                }
            }

            DispatchQueue.global(qos: .default).async {
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

    private func endGesture(size: CGSize) {
        DispatchQueue.main.async {
            isDragged = false

            withAnimation(.spring(response: 0.3)) {
                gestureLocation = CGPoint(x: size.width / 2, y: size.height / 2)
            }
            if let to = vm.draggedTo.value {
                vm.movePiece(fromPosition: position, toPosition: to, isAnimated: false)
            }
        }
        vm.deselectPosition()

        vm.endedGesture()
    }

}

extension SquareView {
    private var backgroundView: some View {
        if position.x % 2 == position.y % 2 {
            return Colors.whiteSquare.opacity(0.3)
        } else {
            return Colors.blackSquare.opacity(0.3)
        }
    }

    private var showFileView: some View {
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

    private var showRankView: some View {
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

    private var allowedMoveView: some View {
        Group {
            if vm.getPiece(atPosition: position) != nil {
                CapturePieceShape()
                    .stroke(.red, style: StrokeStyle(lineWidth: 2, lineJoin: .miter))
                    .padding(1)
                    .opacity(0.8)
            } else {
                Circle()
                    .foregroundStyle(.green)
                    .scaleEffect(CGSize(width: 0.2, height: 0.2))
                    .opacity(0.8)
            }
        }
    }
}

private struct PieceImageView<ViewModel: ViewModelProtocol>: View {

    let piece: Piece
    let isKingInCheckHere: Bool
    let position: Position
    @Binding var turn: PieceColor
    let pieceImageNamespace: Namespace.ID
    @Binding var isDragged: Bool
    @Binding var isSelected: Bool
    @Binding var gestureLocation: CGPoint
    @Binding var size: CGSize
    let shouldRotate: Bool

    var body: some View {
        ZStack {
            if isKingInCheckHere {
                Circle()
                    .foregroundColor(.red)
                    .blur(radius: 8)
                    .padding(size.width / 8)
            }

            if isDragged {
                Image(ImageNames.color[piece.color]! + ImageNames.type[piece.type]!)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding(size.width / 8)
                    .rotationEffect(Angle(degrees: shouldRotate && turn == .black ? 180 : 0))
                    .opacity(0.2)
            }

            Image(ImageNames.color[piece.color]! + ImageNames.type[piece.type]!)
                .resizable()
                .scaledToFit()
                .padding(size.width / 8)
                .matchedGeometryEffect(id: piece.id, in: pieceImageNamespace)
                .scaleEffect(x: isDragged ? 2 : 1, y: isDragged ? 2 : 1)
                .shadow(color: .green, radius: isSelected ? 5 : 0)
                .position(gestureLocation)
                .rotationEffect(Angle(degrees: shouldRotate && turn == .black ? 180 : 0))
                .animation(.spring(response: 0.1), value: isDragged)
        }
    }
}
