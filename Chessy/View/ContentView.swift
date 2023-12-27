//
//  ContentView.swift
//  Chessy
//
//  Created by Yasha Serhiienko on 05.07.2023.
//

import SwiftUI
import WidgetKit

struct ContentView: View {

    private let menuGameView = MenuGameView<GameViewModel<ClassicGame>>()
    private let localGameView = LocalGameView<GameViewModel<ClassicGame>>()
    private let puzzleListView = PuzzleListView()
    private let profileView = ProfileView()
    @Environment(\.scenePhase) private var scenePhase
    @StateObject private var userObject: UserObject = UserObject()

    var body: some View {
        TabView {
            menuGameView
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
                .environmentObject(userObject)
            
            profileView
                .tabItem {
                    Label {
                        Text("Profile")
                    } icon: {
                        Image(systemName: "person.crop.circle")
                    }
                }
                .environmentObject(userObject)
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
