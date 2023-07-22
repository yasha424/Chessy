
//  ContentView.swift
//  Chessy
//
//  Created by Yasha Serhiienko on 05.07.2023.
//

import SwiftUI

struct ContentView: View {
    
    @State var gameView = GameView(game: ClassicGame(board: Board()))
    @State var fenString = ""
    @FocusState var isInputActive: Bool
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [.blue, .yellow],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea(.all)

            Circle()
                .foregroundColor(.purple)
                .frame(width: 400, height: 400, alignment: .center)
                .offset(x: -50, y: -250)
                .opacity(0.6)
                .blur(radius: 5)

            Circle()
                .foregroundColor(.red)
                .frame(width: 300, height: 300, alignment: .center)
                .offset(x: 200, y: -200)
                .opacity(0.6)
                .blur(radius: 5)

            VStack {
                Spacer()
                
                gameView
                    .onShake {
                        gameView.updateGame(with: ClassicGame(board: Board()))
                    }
                    .frame(alignment: .center)
                    .glassView()
                    .padding()
                
                Spacer()
                
                TextField("Input FEN", text: $fenString)
                    .padding()
                    .frame(height: 50)
                    .glassView()
                    .padding()
                    .onSubmit {
                        gameView.updateGame(with: ClassicGame(fromFen: fenString))
                    }
                    .autocorrectionDisabled()
                    .focused($isInputActive)
                    .toolbar {
                        ToolbarItemGroup(placement: .keyboard) {
                            Button("Cancel") {
                                isInputActive = false
                            }
                            Spacer()
                            Button("Done") {
                                isInputActive = false
                                gameView.updateGame(with: ClassicGame(fromFen: fenString))
                            }
                        }
                    }
            }
            .ignoresSafeArea(.keyboard, edges: .bottom)
            .padding([.top, .bottom])
        }
    }
    
}
