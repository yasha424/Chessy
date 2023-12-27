//
//  MenuGameView.swift
//  Chessy
//
//  Created by Yasha Serhiienko on 08.09.2023.
//

import SwiftUI

struct MenuGameView<ViewModel: ViewModelProtocol>: View {

    @StateObject private var vm = GameViewModel(game: ClassicGame(board: Board()))
    private let localGameView = LocalGameView<ViewModel>()
    @State private var presentBotPrefSheet = false
    @State private var preferences: Preferences? = nil
    @State private var selection: String? = nil
    @StateObject private var botVm = BotViewModel(preferences: Preferences(difficulty: .easy, color: .white))

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                NavigationLink {
                    localGameView
                        .environmentObject(vm)
                } label: {
                    Text("New game")
                        .padding()
                        .frame(height: 50)
                        .frame(maxWidth: .infinity)
                        .glassView()
                }
                .simultaneousGesture(TapGesture().onEnded { _ in
                    vm.updateGame(with: ClassicGame(board: Board()))
                })

                NavigationLink {
                    localGameView
                        .environmentObject(vm)
                } label: {
                    Text("Resume game")
                        .padding()
                        .frame(height: 50)
                        .frame(maxWidth: .infinity)
                        .glassView()
                }
                .simultaneousGesture(TapGesture().onEnded { _ in
                    let userDefaults = UserDefaults(suiteName: "group.com.yasha424.ChessyChess")
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
                })
                Button {
                    withAnimation(.spring) {
                        presentBotPrefSheet.toggle()
                    }
                } label: {
                    Text("Play with computer")
                        .padding()
                        .frame(height: 50)
                        .frame(maxWidth: .infinity)
                        .glassView()
                }
                .onChange(of: preferences) { _ in
                    if let preferences = preferences {
                        botVm.changePreferences(with: preferences)
                        botVm.updateGame(with: ClassicGame(board: Board()))
                    }
                    withAnimation(.spring) {
                        presentBotPrefSheet.toggle()
                        selection = "A"
                    }
                }
                NavigationLink(
                    destination: GameView<BotViewModel>().environmentObject(botVm).customBackground(), 
                    tag: "A", selection: $selection
                ) {}
                if presentBotPrefSheet {
                    BotPreferenceView(preferences: $preferences)
                        .frame(height: 200)
                        .glassView()
                        .padding()
                }

            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding()
            .customBackground()
            .navigationTitle("Game")
        }
    }
}

enum Difficulty: String, CaseIterable, Identifiable {
    case veryEasy = "Very Easy"
    case easy, medium, hard
    var id: Self { self }
}

struct Preferences: Equatable {
    let difficulty: Difficulty
    let color: PieceColor
}

private struct BotPreferenceView: View {
    @State private var isBlack = false
    @State private var selectedDifficulty: Difficulty = .easy
    @Binding var preferences: Preferences?
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Spacer()
                Button {
                    preferences = Preferences(difficulty: selectedDifficulty, color: isBlack ? .black : .white)
                } label: {
                    Text("Done")
                }
            }
            .padding()
            Spacer()
            HStack {
                Text("White")
                Toggle("", isOn: $isBlack)
                    .labelsHidden()
                    .tint(.primary.opacity(0.5))
                Text("Black")
            }
            .padding(.horizontal)
            Picker("Difficulty", selection: $selectedDifficulty) {
                ForEach(Difficulty.allCases) { difficulty in
                    Text(difficulty.rawValue.capitalized)
                }
            }
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .customBackground()
    }
}

struct MenuGameViewPreview: PreviewProvider {
    static var previews: some View {
        MenuGameView<GameViewModel<ClassicGame>>()
    }
}
