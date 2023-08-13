//
//  FenInputView.swift
//  Chessy
//
//  Created by Yasha Serhiienko on 01.08.2023.
//

import SwiftUI

struct FenInputView<ChessGame: Game>: View {

    @EnvironmentObject var gameVM: GameViewModel<ChessGame>
    @FocusState var isInputActive: Bool
    @AppStorage("fen") var fenString: String = ""

    var body: some View {
        TextField("Input FEN", text: $fenString)
            .font(.body.monospaced())
            .minimumScaleFactor(0.6)
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
            .onChange(of: gameVM.fen) { _ in
                fenString = gameVM.fen
            }
            .onAppear {
                if let game = ClassicGame(fromFen: fenString) as? ChessGame {
                    gameVM.updateGame(with: game)
                }
                fenString = gameVM.fen
            }
    }
}
