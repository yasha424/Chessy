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

//    init() {
//        self.fenInputView = FenInputView(gameVM: gameVM)
//    }

    var body: some View {
        TabView {
            ZStack {
                LinearGradient(
                    colors: [.blue, .yellow],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea(.all)

                VStack {
                    Spacer()

                    GameView(gameVM: gameVM)
                        .onShake {
                            gameVM.updateGame(with: ClassicGame(board: Board()))
                        }
                        .padding()

                    Spacer()

                    if sizeClass == .regular {
                        fenInputView
//                        TextField("Input FEN", text: $fenString)
//                            .padding([.leading, .trailing])
//                            .frame(height: 40)
//                            .glassView()
                            .padding([.leading, .trailing, .bottom])
//                            .onSubmit {
//                                gameVM.updateGame(with: ClassicGame(fromFen: fenString))
//                            }
//                            .autocorrectionDisabled()
//                            .focused($isInputActive)
//                            .toolbar {
//                                ToolbarItemGroup(placement: .keyboard) {
//                                    Button("Cancel") {
//                                        isInputActive.toggle()
//                                    }
//                                    Spacer()
//                                    Button("Done") {
//                                        isInputActive.toggle()
//                                        gameVM.updateGame(with: ClassicGame(fromFen: fenString))
//                                    }
//                                }
//                            }
                    }
                }
            }
            .tabItem {
                Label("1v1", systemImage: "figure.roll")
            }

            BoardView(gameVM: gameVM)
                .tabItem {
                    Label {
                        Text("Puzzles")
                    } icon: {
                        Image(systemName: "brain.head.profile")
                            .foregroundColor(.white)
                    }
                }
        }
        .onAppear {
            fenInputView = FenInputView(gameVM: gameVM)
        }
        .tint(Color.white)
    }
}
