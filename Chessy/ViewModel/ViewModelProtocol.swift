//
//  ViewModelProtocol.swift
//  Chessy
//
//  Created by Yasha Serhiienko on 15.08.2023.
//

import Foundation

protocol ViewModelProtocol: ObservableObject {
//    var game: any Game { get }
    var game: any Game { get }
    var state: GameState { get }
    var lastMove: Move? { get }
    var draggedTo: Position? { get }
    var kingInCheckForColor: PieceColor? { get }
    var animatedMoves: [Move] { get }
    var selectedPosition: Position? { get }
    var fen: String { get }
    var turn: PieceColor { get }
    var allowedMoves: [Position] { get }
    var canPromotePawnAtPosition: Position? { get }
    var hasTimer: Bool { get }
    var whiteTime: Int? { get }
    var blackTime: Int? { get }
    var audioPlayerService: AudioPlayerService { get }

    func updateGame(with newGame: any Game)
    func undoLastMove()
    func movePiece(fromPosition from: Position, toPosition to: Position, isAnimated: Bool)
    func selectPosition(_ position: Position)
    func deselectPosition()
    func promotePawn(to type: PieceType)
    func getPiece(atPosition position: Position) -> Piece?
    func canSelectPiece(atPosition position: Position) -> Bool
    func computeDraggedPosition(location: CGPoint, size: CGSize)
    func endedGesture()
}

extension ViewModelProtocol {

//    var audioPlayerService: AudioPlayerService = {
//        AudioPlayerService(
//            moveSoundUrl: Bundle.main.url(forResource: "move", withExtension: "mp3"),
//            captureSoundUrl: Bundle.main.url(forResource: "capture", withExtension: "mp3")
//        )
//    }()

}
