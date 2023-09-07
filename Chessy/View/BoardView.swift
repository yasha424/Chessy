//
//  BoardView.swift
//  Chessy
//
//  Created by Yasha Serhiienko on 24.07.2023.
//

import SwiftUI

struct BoardView<ViewModel: ViewModelProtocol>: View {

    @ObservedObject var vm: ViewModel
//    @State private var board: Board = Board()
    @Binding var shouldRotate: Bool
    @State private var selectedPosition: Position?
    @State private var lastMove: Move?
    @Namespace private var pieceImageNamespace

    var body: some View {
        ZStack {
            squaresBoardView
                .onReceive(vm.selectedPosition) {
                    if selectedPosition != $0 {
                        selectedPosition = $0
                    }
                }
                .onReceive(vm.lastMove) {
                    if lastMove != $0 {
                        lastMove = $0
                    }
                }

            promotionView
        }
        .aspectRatio(1, contentMode: .fit)
        .glassView()
    }
}

extension BoardView {
    private var squaresBoardView: some View {
        if #available(iOS 16.0, *) {
            return Grid(horizontalSpacing: 0, verticalSpacing: 0) {
                ForEach(0..<8) { i in
                    GridRow {
                        ForEach(0..<8) { j in
                            let position = Position(rawValue: (7 - i) * 8 + j)!

                            SquareView<ViewModel>(
                                vm: vm,
                                position: position,
                                shouldRotate: shouldRotate,
                                pieceImageNamespace: pieceImageNamespace
                            )
                            .zIndex(selectedPosition == position ? 2 :
                                        (lastMove?.to == position ? 1 : 0))
                        }
                    }
                }
            }
            .padding(10)
        } else {
            return VStack(spacing: 0) {
                ForEach(0..<8) { i in
                    HStack(spacing: 0) {
                        ForEach(0..<8) { j in
                            let position = Position(rawValue: (7 - i) * 8 + j)!

                            SquareView<ViewModel>(
                                vm: vm,
                                position: position,
                                shouldRotate: shouldRotate,
                                pieceImageNamespace: pieceImageNamespace
                            )
                            .zIndex(selectedPosition == position ? 2 :
                                        (lastMove?.to == position ? 1 : 0))
                        }
                    }
                    .zIndex(selectedPosition?.x == 7 - i ? 2 :
                                (lastMove?.to.x == 7 - i ? 1 : 0))
                }
            }
            .padding(10)
        }
    }

    private var promotionView: some View {
        ZStack {
            if let position = vm.canPromotePawnAtPosition {
                Color.black.opacity(0.3)
                VStack {
                    Spacer()
                    HStack(spacing: 16) {
                        let pieceTypes: [PieceType] = [.queen, .rook, .bishop, .knight]
                        Spacer()
                        ForEach(pieceTypes) { type in
                            Button {
                                vm.promotePawn(to: type)
                            } label: {
                                if let piece = vm.getPiece(atPosition: position),
                                   let colorName = ImageNames.color[piece.color],
                                   let typeName = ImageNames.type[type] {
                                    let rotationDegrees = (shouldRotate &&
                                                           vm.turn.value == .black) ? 180.0 : 0.0
                                    Image(colorName + typeName)
                                        .resizable()
                                        .padding(8)
                                        .rotationEffect(Angle(
                                            degrees: rotationDegrees
                                        ))
                                }
                            }
                            .aspectRatio(1, contentMode: .fit)
                            .frame(minWidth: 20, maxWidth: 60, minHeight: 20, maxHeight: 60)
                            .glassView()
                            Spacer()
                        }
                    }
                    Spacer()
                }
            }
        }
    }
}
