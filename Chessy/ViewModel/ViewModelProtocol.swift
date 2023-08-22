//
//  ViewModelProtocol.swift
//  Chessy
//
//  Created by Yasha Serhiienko on 15.08.2023.
//

import Foundation

protocol ViewModelProtocol: ObservableObject {
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
    var whiteCapturedPiece: [PieceType: Int] { get }
    var blackCapturedPiece: [PieceType: Int] { get }
    var value: Int { get }

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
    func capturedPieces(for color: PieceColor) -> [PieceType: Int] {
        var pieces: [PieceType: Int] = [.queen: 1, .rook: 2, .bishop: 2, .knight: 2, .pawn: 8]
        for piece in game.board.pieces where piece != nil && piece?.type != .king {
            guard let piece = piece else { return [:] }
            if piece.color == color {
                pieces[piece.type]! -= 1
            }
        }
        return pieces
    }
}
