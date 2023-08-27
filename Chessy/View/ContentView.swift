//
//  ContentView.swift
//  Chessy
//
//  Created by Yasha Serhiienko on 05.07.2023.
//

import SwiftUI
import WidgetKit

struct ContentView: View {

    @StateObject private var gameVM: GameViewModel = {
        let userDefaults = UserDefaults(suiteName: "group.com.yasha424.Chessy.default")!
        let fen = userDefaults.string(forKey: "fen") ?? ""
        let game = ClassicGame(fromFen: fen)
        let timer = GameTimer(seconds: 0)
        let whiteTime = UserDefaults.standard.integer(forKey: "whiteTime")
        let blackTime = UserDefaults.standard.integer(forKey: "blackTime")
        game.timer = timer
        timer.delegate = game
        timer.set(seconds: whiteTime, for: .white)
        timer.set(seconds: blackTime, for: .black)
        return GameViewModel(game: game)
    }()
    private let singlePlayerGameView = SinglePlayerGameView<GameViewModel<ClassicGame>>()
    private let puzzleListView = PuzzleListView()
    @Environment(\.scenePhase) private var scenePhase

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
