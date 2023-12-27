//
//  CreatePuzzleMovesView.swift
//  Chessy
//
//  Created by yasha on 23.12.2023.
//

import SwiftUI

struct CreatePuzzleMovesView: View {
    let vm: PuzzleViewModel
    @Binding var isSuccessful: Bool
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject private var userObject: UserObject
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
            }
            .padding(16)
            Spacer()
            BoardView(vm: vm, shouldRotate: .constant(false))
                .padding(8)
            Spacer()
        }
        .customBackground()
        .toolbar {
            Button {
                Task {
                    await vm.savePuzzle(userObject.user?.email)
                    isSuccessful = true
                    presentationMode.wrappedValue.dismiss()
                }
            } label: {
                Text("Done")
            }
        }
    }
}
