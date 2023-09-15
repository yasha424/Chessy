//
//  MenuGameView.swift
//  Chessy
//
//  Created by Yasha Serhiienko on 08.09.2023.
//

import SwiftUI

struct MenuGameView<ViewModel: ViewModelProtocol>: View {

    @StateObject private var vm: GameViewModel = GameViewModel(game: ClassicGame(board: Board()))
    private let localGameView = LocalGameView<ViewModel>()

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                NavigationLink {
                    localGameView
                        .environmentObject(vm)
                        .onAppear {
                            vm.updateGame(with: ClassicGame(board: Board()))
                        }
                } label: {
                    Text("New game")
                        .padding()
                        .frame(height: 50)
                        .frame(maxWidth: .infinity)
                        .glassView()
                }

                NavigationLink {
                    localGameView
                        .environmentObject(vm)
                        .onAppear {
                            let userDefaults = UserDefaults(
                                suiteName: "group.com.yasha424.Chessy.default"
                            )
                            if let fen = userDefaults?.string(forKey: "fen") {
                                let game = ClassicGame(fromFen: fen)
                                let timer = GameTimer(seconds: 0)
                                let whiteTime = UserDefaults.standard.integer(forKey: "whiteTime")
                                let blackTime = UserDefaults.standard.integer(forKey: "blackTime")
                                game.timer = timer
                                timer.delegate = game
                                timer.set(seconds: whiteTime, for: .white)
                                timer.set(seconds: blackTime, for: .black)
                                vm.updateGame(with: game)
                            }
                        }
                } label: {
                    Text("Resume game")
                        .padding()
                        .frame(height: 50)
                        .frame(maxWidth: .infinity)
                        .glassView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding()
            .customBackground()
            .navigationTitle("Local game")
        }
    }
}

struct MenuGameViewPreview: PreviewProvider {
    static var previews: some View {
        MenuGameView<GameViewModel<ClassicGame>>()
    }
}
