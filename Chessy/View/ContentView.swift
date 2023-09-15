//
//  ContentView.swift
//  Chessy
//
//  Created by Yasha Serhiienko on 05.07.2023.
//

import SwiftUI
import WidgetKit

struct ContentView: View {

    private let localGameView = LocalGameView<GameViewModel<ClassicGame>>()
    private let puzzleListView = PuzzleListView()
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        TabView {
            MenuGameView<GameViewModel<ClassicGame>>()
                .tabItem {
                    Label {
                        Text("Local game")
                    } icon: {
                        Image(systemName: "play")
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
