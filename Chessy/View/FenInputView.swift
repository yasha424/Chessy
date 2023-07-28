//
//  FenInputView.swift
//  Chessy
//
//  Created by Yasha Serhiienko on 26.07.2023.
//

import SwiftUI

struct FenInputView<ChessGame: Game>: View {
    @Binding var gameView: GameView<ChessGame>
    @State var fenString = ""
    @FocusState var isInputActive: Bool

    var body: some View {
        TextField("Input FEN", text: $fenString)
            .padding()
            .frame(height: 40)
            .glassView()
            .padding([.leading, .trailing])
            .onSubmit {
                if let game = ClassicGame(fromFen: fenString) as? ChessGame {
                    gameView.updateGame(with: game)
                }
            }
            .autocorrectionDisabled()
            .focused($isInputActive)
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Button("Cancel") {
                        isInputActive.toggle()
                    }
                    Spacer()
                    Button("Done") {
                        isInputActive.toggle()
                        if let game = ClassicGame(fromFen: fenString) as? ChessGame {
                            gameView.updateGame(with: game)
                        }
                    }
                }
            }
    }
}
