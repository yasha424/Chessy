//
//  ContentView.swift
//  Chessy
//
//  Created by Yasha Serhiienko on 05.07.2023.
//

import SwiftUI

struct ContentView: View {

    @StateObject var gameVM = GameViewModel(game: ClassicGame(board: Board()))

    let singlePlayerGameView = SinglePlayerGameView()

    @Environment(\.verticalSizeClass) var sizeClass

    var body: some View {
        TabView {
            singlePlayerGameView
                .environmentObject(gameVM)
                .tabItem {
                    Label("1v1", systemImage: "figure.roll")
                }

            PuzzleView()
        }
        .onAppear {
            UITabBar.appearance().backgroundColor = UIColor.systemBackground.withAlphaComponent(0.3)
        }
        .tint(.primary)
    }
}
