
//  ContentView.swift
//  Chessy
//
//  Created by Yasha Serhiienko on 05.07.2023.
//

import SwiftUI

struct ContentView: View {
    
    @State var board = Board()
    
    var body: some View {
        BoardView(board: board)
            .onAppear {}
            .onShake {
                board = Board()
            }
    }
    
}
