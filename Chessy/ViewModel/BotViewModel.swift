//
//  BotViewModel.swift
//  Chessy
//
//  Created by yasha on 24.12.2023.
//

import ChessKitEngine

class BotViewModel: GameViewModel<ClassicGame> {
    private let engine: Engine
    private var playerColor: PieceColor
    private var time: Int = 50
    private var depth: Int = 2
    
    init(preferences: Preferences) {
        self.engine = Engine(type: .stockfish)
        self.playerColor = preferences.color
        
        
        super.init(game: ClassicGame(board: Board()))
        
        setDifficulty(preferences.difficulty)
        engine.receiveResponse = { response in
            switch response {
            case let .info(info):
                if let pv = info.pv, let time = info.time, (time > self.time || info.depth == self.depth) {
                    if !pv.isEmpty {
                        guard let moveString = pv.first else { return }
                        let move = Move(fromString: moveString)
                        super.movePiece(fromPosition: move.from, toPosition: move.to, isAnimated: false)
                        self.engine.send(command: .stop)
                    }
                }
            default:
                break
            }
        }
        engine.start()
    }
    
    override func movePiece(fromPosition from: Position, toPosition to: Position, isAnimated: Bool = false) {
        if self.game.turn == playerColor {
            super.movePiece(fromPosition: from, toPosition: to, isAnimated: isAnimated)
            let fen = self.game.fen
            engine.send(command: .stop)
            engine.send(command: .position(.fen(fen)))
            engine.send(command: .go(depth: depth))
        }
    }
    
    func changePreferences(with preferences: Preferences) {
        self.playerColor = preferences.color
        
        setDifficulty(preferences.difficulty)

        if playerColor == .black {
            let fen = self.game.fen
            engine.send(command: .position(.fen(fen)))
            engine.send(command: .go(depth: depth))
        }
    }
    
    func setDifficulty(_ difficulty: Difficulty) {
        switch difficulty {
        case .veryEasy:
            self.time = 10
            self.depth = 1
        case .easy:
            self.time = 50
            self.depth = 2
        case .medium:
            self.time = 100
            self.depth = 5
        case .hard:
            self.time = 300
            self.depth = 10
        }
    }
}
