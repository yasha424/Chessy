//
//  FenInputView.swift
//  Chessy
//
//  Created by Yasha Serhiienko on 01.08.2023.
//

import SwiftUI

struct FenInputView<ChessGame: Game>: View {

    @ObservedObject var gameVM: GameViewModel<ChessGame>
    @State var fenString = ""
    @FocusState var isInputActive: Bool

    var body: some View {
        TextField("Input FEN", text: $fenString)
            .padding([.leading, .trailing])
            .frame(height: 40)
            .glassView()
            .autocorrectionDisabled()
            .focused($isInputActive)
            .onSubmit {
                if let game = ClassicGame(fromFen: fenString) as? ChessGame {
                    gameVM.updateGame(with: game)
                }
            }
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Button("Cancel") {
                        isInputActive.toggle()
                    }
                    Spacer()
                    Button("Done") {
                        isInputActive.toggle()
                        if let game = ClassicGame(fromFen: fenString) as? ChessGame {
                            gameVM.updateGame(with: game)
                        }
                    }
                }
            }
    }
}