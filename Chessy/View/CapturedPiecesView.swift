//
//  CapturedPiecesView.swift
//  Chessy
//
//  Created by Yasha Serhiienko on 23.08.2023.
//

import SwiftUI

struct CapturedPiecesView<ViewModel: ViewModelProtocol>: View {

    let color: PieceColor
    @EnvironmentObject private var gameVM: ViewModel
    @State private var capturedPieces = [PieceType: Int]()
    @State private var value: Int = 0
    @State private var turn: PieceColor = .white
    @State private var isShown = true
    @AppStorage("shouldRotate") private var shouldRotate = false

    var body: some View {
        HStack(spacing: 0) {
            if isShown {
                let pieces = capturedPieces.sorted {
                    $0.key.value > $1.key.value
                }
                ForEach(pieces, id: \.key) { pieceType, num in
                    if num > 0 {
                        ZStack {
                            ForEach(0..<num, id: \.self) { i in
                                Image(ImageNames.color[color]! +
                                      ImageNames.type[pieceType]!)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .offset(x: (CGFloat(i) - CGFloat(num) / 2) * 10 + 5)
                                .transition(.scale)
                            }
                        }
                        .frame(width: 26 + CGFloat(num - 1) * 10)
                    }
                }
                if (value < 0 && color == .white) || (value > 0 && color == .black) {
                    Text("+\(abs(value))")
                        .font(.body.monospaced())
                        .opacity(0.5)
                        .frame(width: 40)
                        .minimumScaleFactor(0.5)
                        .transition(.scale)
                }
            }
        }
        .padding(8)
        .frame(height: 40)
        .animation(.spring(response: 0.5), value: capturedPieces)
        .animation(.spring(response: 0.5), value: value)
        .rotationEffect(
            Angle(degrees: shouldRotate && turn == .black ? 180 : 0)
        )
        .glassView()
        .onTapGesture {
            withAnimation(.spring(response: 0.5)) {
                isShown.toggle()
            }
        }
        .onReceive(color == .white ? gameVM.whiteCapturedPieces : gameVM.blackCapturedPieces) {
            if capturedPieces != $0 {
                capturedPieces = $0
            }
        }
        .onReceive(gameVM.value) {
            if (color == .white && $0 < 0) || (color == .black && $0 > 0) {
                if value != $0 {
                    value = $0
                }
            } else {
                value = 0
            }
        }
        .onReceive(gameVM.turn) {
            if turn != $0 {
                turn = $0
            }
        }
    }
}
