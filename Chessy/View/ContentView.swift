
//  ContentView.swift
//  Chessy
//
//  Created by Yasha Serhiienko on 05.07.2023.
//

import SwiftUI

struct ContentView: View {
    
//    @State var board = Board()
    @State var game = ClassicGame(board: Board())
    
    var body: some View {
        BoardView(game: game)
            .onAppear {}
            .onShake {
                game = ClassicGame(board: Board())
            }
        
        Button(action: {
            game = ClassicGame(board: Board())
        }, label: {
            Text("Reload board")
        })
    }
    
}
