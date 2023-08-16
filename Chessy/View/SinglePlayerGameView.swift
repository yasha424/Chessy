//
//  SinglePlayerGameView.swift
//  Chessy
//
//  Created by Yasha Serhiienko on 13.08.2023.
//

import SwiftUI

struct SinglePlayerGameView<ViewModel: ViewModelProtocol>: View {

    @EnvironmentObject var gameVM: ViewModel

    @State var isAlertPresented = false
    @AppStorage("shouldRotate") var shouldRotate = false

    let fenInputView = FenInputView<ClassicGame>()
    let gameView = GameView<ViewModel>()

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            gameView
                .onShake { isAlertPresented = true }
                .padding([.leading, .trailing, .bottom], 8)

            Spacer()

            HStack {
                Spacer()
                HStack {
                    Text("Rotating")
                        .foregroundColor(.primary)
                        .font(.title3)
                    Toggle("", isOn: $shouldRotate)
                        .labelsHidden()
                }
                .padding([.leading, .trailing], 8)
                .frame(height: 40)
                .glassView()
                .tint(.primary.opacity(0.5))
            }
            .padding(8)

            fenInputView.padding(8)
        }
        .customBackground()
        .alert("Reset game?", isPresented: $isAlertPresented, actions: {
            Button(role: .destructive) {
                gameVM.updateGame(with: ClassicGame(board: Board()))
            } label: {
                Text("Reset")
            }
        }, message: {
            Text("You will lose current game progress")
        })
    }
}
