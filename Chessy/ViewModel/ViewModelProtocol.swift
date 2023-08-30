//
//  ViewModelProtocol.swift
//  Chessy
//
//  Created by Yasha Serhiienko on 15.08.2023.
//

import Foundation
import Combine

protocol ViewModelProtocol: ObservableObject {
    var game: any Game { get }
    var state: GameState { get }
    var lastMove: CurrentValueSubject<Move?, Never> { get }
    var draggedTo: CurrentValueSubject<Position?, Never> { get }
    var kingInCheckForColor: PieceColor? { get }
    var animatedMoves: [Move] { get }
    var selectedPosition: CurrentValueSubject<Position?, Never> { get }
    var fen: CurrentValueSubject<String, Never> { get }
    var turn: CurrentValueSubject<PieceColor, Never> { get }
    var allowedMoves: CurrentValueSubject<[Position], Never> { get }
    var canPromotePawnAtPosition: Position? { get }
    var hasTimer: Bool { get }
    var whiteTime: CurrentValueSubject<Int?, Never> { get }
    var blackTime: CurrentValueSubject<Int?, Never> { get }
    var audioPlayerService: AudioPlayerService { get }
    var whiteCapturedPieces: CurrentValueSubject<[PieceType: Int], Never> { get }
    var blackCapturedPieces: CurrentValueSubject<[PieceType: Int], Never> { get }
    var value: CurrentValueSubject<Int, Never> { get }
    var didUpdateGame: CurrentValueSubject<Bool, Never> { get }
    var undidMove: CurrentValueSubject<Move?, Never> { get }

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
    func setTime(seconds: Int, for color: PieceColor)
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
