
//  ContentView.swift
//  Chessy
//
//  Created by Yasha Serhiienko on 05.07.2023.
//

import SwiftUI

struct ContentView: View {
    
    @State var board = Board()
    
    var body: some View {
        BoardView()
//        VStack {
            
        .onAppear {
//            board.display()
//            board.movePiece(fromPosition: .a2, toPosition: .a4)
//            board.movePiece(fromPosition: .b7, toPosition: .b5)
//            board.movePiece(fromPosition: .a4, toPosition: .b5)
//            board.movePiece(fromPosition: .b5, toPosition: .b6)
//            board.movePiece(fromPosition: .b6, toPosition: .b7)
//            board.movePiece(fromPosition: .b7, toPosition: .a8)
//            movePieces()
//            board.movePiece(fromPosition: .c8, toPosition: .a6)
//            board.movePiece(fromPosition: .a6, toPosition: .f1)

//            board.movePiece(fromPosition: .c8, toPosition: .a5)
//            board.movePiece(fromPosition: .f8, toPosition: .e7)
            
//            board.movePiece(fromPosition: .b1, toPosition: .c3)
//            board.movePiece(fromPosition: .a2, toPosition: .a3)
//            board.movePiece(fromPosition: .c3, toPosition: .a2)
//            board.movePiece(fromPosition: .a2, toPosition: .c3)
//            board.movePiece(fromPosition: .c3, toPosition: .b1)
//            board.movePiece(fromPosition: .b1, toPosition: .c3)
//            board.movePiece(fromPosition: .c3, toPosition: .d5)
//            board.movePiece(fromPosition: .d5, toPosition: .b6)
            
//            board.movePiece(fromPosition: .a2, toPosition: .a4)

//            board.movePiece(fromPosition: .a1, toPosition: .a3)
//            board.movePiece(fromPosition: .a3, toPosition: .b3)
//            board.movePiece(fromPosition: .b3, toPosition: .b7)
//            board.movePiece(fromPosition: .b7, toPosition: .a1)
//            board.movePiece(fromPosition: .b7, toPosition: .b8)
//            board.movePiece(fromPosition: .b8, toPosition: .a8)

//            board.movePiece(fromPosition: .d1, toPosition: .c2)
//            board.movePiece(fromPosition: .d1, toPosition: .d2)
//            board.movePiece(fromPosition: .d2, toPosition: .d4)
//            board.movePiece(fromPosition: .d1, toPosition: .d2)
//            board.movePiece(fromPosition: .d2, toPosition: .h6)
//            board.movePiece(fromPosition: .h6, toPosition: .a6)
//            board.movePiece(fromPosition: .a6, toPosition: .c8)
//            board.movePiece(fromPosition: .a6, toPosition: .a2)
//            board.movePiece(fromPosition: .a6, toPosition: .b3)
//            board.movePiece(fromPosition: .a6, toPosition: .b7)



            board.display()
        }
    }
    
    func movePieces() {
        board.movePiece(fromPosition: .a2, toPosition: .a4)
        board.movePiece(fromPosition: .a2, toPosition: .a4)
        board.movePiece(fromPosition: .a4, toPosition: .a5)
    }

}
