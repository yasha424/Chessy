//
//  FenInputView.swift
//  Chessy
//
//  Created by Yasha Serhiienko on 01.08.2023.
//

import SwiftUI

struct FenInputView<ChessGame: Game>: View {

    @EnvironmentObject private var vm: GameViewModel<ChessGame>
    @FocusState private var isInputActive: Bool
    @AppStorage("fen", store: UserDefaults(suiteName: "group.com.yasha424.Chessy.default"))
    private var fenString: String = ""

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
                    vm.updateGame(with: game)
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
                            vm.updateGame(with: game)
                        }
                    }
                }
            }
            .onReceive(vm.fen) {
                fenString = $0
            }
    }
}
