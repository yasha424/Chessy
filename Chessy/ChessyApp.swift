//
//  ChessyApp.swift
//  Chessy
//
//  Created by Yasha Serhiienko on 05.07.2023.
//

import SwiftUI

@main
struct ChessyApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .commands {
            SidebarCommands()
            CommandGroup(replacing: .newItem) {
                Button("Reset game") {
                    if !UserDefaults.standard.bool(forKey: "shouldUpdateGame") {
                        UserDefaults.standard.set(true, forKey: "shouldUpdateGame")
                    } else {
                        UserDefaults.standard.set(false, forKey: "shouldUpdateGame")
                    }
                }.keyboardShortcut("r")
            }
            CommandGroup(replacing: .undoRedo) {
                Button("Undo move") {
                    if !UserDefaults.standard.bool(forKey: "shouldUndoMove") {
                        UserDefaults.standard.set(true, forKey: "shouldUndoMove")
                    } else {
                        UserDefaults.standard.set(false, forKey: "shouldUndoMove")
                    }
                }.keyboardShortcut("z")
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
