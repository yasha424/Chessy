//
//  BoardView.swift
//  Chessy
//
//  Created by Yasha Serhiienko on 09.07.2023.
//

import SwiftUI

struct GameView<ChessGame>: View where ChessGame: Game {
    
    @ObservedObject var game: ChessGame
    private var boardView: BoardView<ChessGame>
    @Environment(\.verticalSizeClass) var sizeClass
    
    init(game: ChessGame) {
        self.game = game
        self.boardView = BoardView(game: game)
    }
    
    var body: some View {
        VStack {
            if sizeClass == .regular {
                HStack {
                    Spacer()
                    TimerView(game: game, color: .black)
                        .padding([.top, .trailing])
                }
            
                BoardView(game: game)

                HStack {
                    Spacer()
                    TimerView(game: game, color: .white)
                        .padding([.bottom, .trailing])
                }
            } else {
                HStack {
                    BoardView(game: game)
                    
                    VStack {
                        TimerView(game: game, color: .black)
                            .padding(.top)
                        Spacer()
                        TimerView(game: game, color: .white)
                            .padding(.bottom)
                    }
                }
            }
        }
    }
    
    
    mutating func updateGame(with newGame: ChessGame) {
        game = newGame
        boardView.reset()
    }
    
}
