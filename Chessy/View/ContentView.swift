//
//  ContentView.swift
//  Chessy
//
//  Created by Yasha Serhiienko on 05.07.2023.
//

import SwiftUI

struct ContentView: View {

    @StateObject var gameVM = GameViewModel(game: ClassicGame(board: Board()))

    @State var fenInputView: FenInputView<ClassicGame>!

    @Environment(\.verticalSizeClass) var sizeClass

    @State var shouldRotate = false

    var body: some View {
        TabView {
            ZStack {
                LinearGradient(
                    colors: [.blue, .yellow],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                VStack {
                    Spacer()

                    GameView(gameVM: gameVM)
                        .onShake {
                            gameVM.updateGame(with: ClassicGame(board: Board()))
                        }
                        .padding([.leading, .trailing, .bottom])

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
                        .padding([.leading, .trailing])
                        .frame(height: 40)
                        .glassView()
                        .tint(.primary.opacity(0.5))
                    }
                    .padding([.leading, .trailing, .vertical])

                    Spacer()

                    if sizeClass == .regular {
                        fenInputView
                            .padding()
                    }
                }
            }
            .ignoresSafeArea(edges: .top)
            .tabItem {
                Label("1v1", systemImage: "figure.roll")
            }

            PuzzleView()
        }
        .environment(\.shouldRotate, shouldRotate)
        .onAppear {
            fenInputView = FenInputView(gameVM: gameVM)

            UITabBar.appearance().backgroundColor = UIColor.systemBackground.withAlphaComponent(0.3)
        }
        .tint(.primary)
    }
}
