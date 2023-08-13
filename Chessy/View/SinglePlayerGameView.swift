//
//  SinglePlayerGameView.swift
//  Chessy
//
//  Created by Yasha Serhiienko on 13.08.2023.
//

import SwiftUI

struct SinglePlayerGameView: View {

    @EnvironmentObject var gameVM: GameViewModel<ClassicGame>

    @State var isAlertPresented = false
    @AppStorage("shouldRotate") var shouldRotate = false

    let fenInputView = FenInputView<ClassicGame>()
    let gameView = GameView<ClassicGame>()

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            gameView
                .onShake {
                    isAlertPresented = true
                }
                .padding([.leading, .trailing, .bottom])

            HStack {
                Spacer()
                HStack {
                    Text("Rotating")
                        .foregroundColor(.primary)
                        .font(.title3)
                    Toggle("", isOn: $shouldRotate)
                        .labelsHidden()
                }
                .padding([.leading, .trailing])
                .frame(height: 40)
                .glassView()
                .tint(.primary.opacity(0.5))
            }
            .padding(.horizontal)

            Spacer()

            fenInputView.padding()
        }
        .background(.thinMaterial)
        .background(
            LinearGradient(
                colors: [.blue, .yellow],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            ignoresSafeAreaEdges: .all
        )
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
