//
//  ContentView.swift
//  Chessy
//
//  Created by Yasha Serhiienko on 05.07.2023.
//

import SwiftUI
import WidgetKit

struct ContentView: View {

    @StateObject var gameVM = GameViewModel(game: ClassicGame(board: Board()))
    let singlePlayerGameView = SinglePlayerGameView<GameViewModel<ClassicGame>>()
    let puzzleListView = PuzzleListView()
    @Environment(\.scenePhase) var scenePhase

    var body: some View {
        TabView {
            singlePlayerGameView
                .environmentObject(gameVM)
                .tabItem {
                    Label {
                        Text("1v1")
                    } icon: {
                        Image(systemName: "play.circle.fill")
                    }
                }

            puzzleListView
                .tabItem {
                    Label {
                        Text("Puzzles")
                    } icon: {
                        Image(systemName: "brain.head.profile")
                    }
                }
        }
        .onChange(of: scenePhase) { newPhase in
            if newPhase == .background {
                WidgetCenter.shared.reloadAllTimelines()
            }
        }
        .onAppear {
            UITabBar.appearance().backgroundColor = UIColor.systemBackground.withAlphaComponent(0.3)
        }
        .tint(.primary)
    }
}
