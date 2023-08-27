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
    @State private var isShown = true
    @AppStorage("shouldRotate") private var shouldRotate = false

    var body: some View {
        HStack(spacing: 0) {
            if isShown {
                let capturedPieces = color == .white ?
                    gameVM.whiteCapturedPieces : gameVM.blackCapturedPieces
                let pieces = capturedPieces.sorted { first, second in
                    first.key.value > second.key.value
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
                if (gameVM.value < 0 && color == .white) || (gameVM.value > 0 && color == .black) {
                    Text("+\(abs(gameVM.value))")
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
        .animation(
            .spring(response: 0.5),
            value: color == .white ? gameVM.whiteCapturedPieces : gameVM.blackCapturedPieces
        )
        .animation(.spring(response: 0.5), value: gameVM.value)
        .rotationEffect(
            Angle(degrees: gameVM.turn == .black && shouldRotate ? 180 : 0)
        )
        .glassView()
        .onTapGesture {
            withAnimation(.spring(response: 0.5)) {
                isShown.toggle()
            }
        }
    }
}
