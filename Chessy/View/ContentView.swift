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
                    Label {
                        Text("1v1")
                    } icon: {
                        Image(systemName: "play.circle")
                    }

                }

            PuzzleView()
        }
        .onAppear {
            UITabBar.appearance().backgroundColor = UIColor.systemBackground.withAlphaComponent(0.3)
        }
        .tint(.primary)
    }
}
