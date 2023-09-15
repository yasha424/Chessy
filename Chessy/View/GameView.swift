//
//  BoardView.swift
//  Chessy
//
//  Created by Yasha Serhiienko on 09.07.2023.
//

import SwiftUI

struct GameView<ViewModel: ViewModelProtocol>: View {

    @EnvironmentObject private var vm: ViewModel

    @State private var boardView: BoardView<ViewModel>!
    private let blackTimerView = TimerView<ClassicGame>(color: .black)
    private let whiteTimerView = TimerView<ClassicGame>(color: .white)
    private let undoButtonView = UndoButtonView<ClassicGame>()
    private let whiteCapturedPiecesView = CapturedPiecesView<ViewModel>(color: .white)
    private let blackCapturedPiecesView = CapturedPiecesView<ViewModel>(color: .black)
    @State private var gameState: GameState = .inProgress
    @AppStorage("shouldRotate") private var shouldRotate = false
    @Namespace var namespace
    @Environment(\.verticalSizeClass) private var sizeClass

    var body: some View {
        ZStack {
            if sizeClass == .regular {
                VStack {
                    blackInfoView
                    boardView.padding(.vertical, 8)
                        .matchedGeometryEffect(id: "boardView", in: namespace)
                    whiteInfoView
                    HStack {
                        undoButtonView
                        Spacer()
                        switchRotateView
                    }
                    .padding(.top, 8)
                    Spacer()
                }
                .padding(.vertical, 8)
            } else {
                HStack {
                    VStack(alignment: .leading) {
                        whiteCapturedPiecesView
                        Spacer()
                        blackCapturedPiecesView
                    }
                    Spacer()
                }
                .padding(.vertical, 8)
                HStack {
                    Spacer()
                    VStack(alignment: .trailing) {
                        blackTimerView
                        Spacer()
                        switchRotateView
                        Spacer()
                        whiteTimerView
                    }
                    .padding(.vertical, 8)
                }
                HStack {
                    undoButtonView
                    boardView.padding(8)
                }
            }
            gameStateNotificationView
                .ignoresSafeArea()
        }
        .padding(.horizontal, 8)
        .onAppear {
            self.boardView = BoardView<ViewModel>(vm: vm, shouldRotate: $shouldRotate)
            self.gameState = vm.state.value
        }
    }
}

extension GameView {
    private var gameStateNotificationView: some View {
        VStack {
            switch gameState {
            case .checkmate(let color):
                if color == .white {
                    Text("Black won by checkmate!")
                        .padding()
                        .frame(height: 40)
                        .glassView()
                        .padding([.top, .bottom], 100)
                        .transition(.move(edge: .top))
                } else {
                    Text("White won by checkmate!")
                        .padding()
                        .frame(height: 40)
                        .glassView()
                        .padding([.top, .bottom], 100)
                        .transition(.move(edge: .top))
                }
            case .stalemate:
                Text("Stalemate!")
                    .padding()
                    .frame(height: 40)
                    .glassView()
                    .padding([.top, .bottom], 100)
                    .transition(.move(edge: .top))
            default:
                EmptyView()
            }

            Spacer()
        }
        .animation(.spring(response: 0.3), value: gameState)
        .onReceive(vm.state) {
            if self.gameState != $0 {
                self.gameState = $0
            }
        }
    }

    private var blackInfoView: some View {
        HStack {
            whiteCapturedPiecesView

            Spacer()

            if vm.hasTimer {
                blackTimerView
            }
        }
    }

    private var whiteInfoView: some View {
        HStack {
            blackCapturedPiecesView

            Spacer()

            if vm.hasTimer {
                whiteTimerView
            }
        }
    }

    private var switchRotateView: some View {
//        HStack {
//            Spacer()
            HStack {
                Text("Rotating")
                    .foregroundColor(.primary)
                    .font(.title3)
                Toggle("", isOn: $shouldRotate)
                    .labelsHidden()
            }
            .padding([.leading, .trailing], 8)
            .frame(height: 40)
            .glassView()
            .tint(.primary.opacity(0.5))
//        }
    }
}

struct GameViewPreview: PreviewProvider {
    static var previews: some View {
        GameView<GameViewModel<ClassicGame>>()
            .environmentObject(GameViewModel(game: ClassicGame(board: Board())))
    }
}
