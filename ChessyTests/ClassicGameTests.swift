//
//  ChessyTests.swift
//  ChessyTests
//
//  Created by Yasha Serhiienko on 05.07.2023.
//

import XCTest
@testable import Chessy

final class ClassicGameTests: XCTestCase {

    func testPawnMove() {
        let game = ClassicGame(board: Board())
        game.movePiece(fromPosition: .e2, toPosition: .e4)
        game.movePiece(fromPosition: .e7, toPosition: .e5)
        XCTAssertEqual(
            game.board,
            Board(fromFen: "rnbqkbnr/pppp1ppp/8/4p3/4P3/8/PPPP1PPP/RNBQKBNR")
        )
        XCTAssertEqual(
            game.history,
            [Move(
                from: .e2,
                to: .e4,
                piece: Piece(color: .white, type: .pawn),
                castling: nil,
                capturedPiece: nil,
                capturedByEnPassant: false,
                timeLeft: 30
            ),
             Move(
                from: .e7,
                to: .e5,
                piece: Piece(color: .black, type: .pawn),
                castling: nil,
                capturedPiece: nil,
                capturedByEnPassant: false,
                timeLeft: 33
             )]
        )
    }

    func testFenInit() {
        let game = ClassicGame(
            fromFen: "8/p6k/8/8/8/8/8/P6K w KQkq - 1 2"
        )
        XCTAssertNotNil(game.board[.a7])
        XCTAssertNotNil(game.board[.h7])
        XCTAssertNotNil(game.board[.a1])
        XCTAssertNotNil(game.board[.h1])
    }

    func testPawnPromotion() {
        let game = ClassicGame(
            fromFen: "8/P6k/8/8/8/8/8/P6K w KQkq - 1 2"
        )
        XCTAssertNil(game.canPromotePawnAtPosition)
        game.movePiece(fromPosition: .a7, toPosition: .a8)
        XCTAssertNotNil(game.canPromotePawnAtPosition)
        XCTAssertEqual(game.canPromotePawnAtPosition, .a8)
        game.movePiece(fromPosition: .a1, toPosition: .a2)
        game.promotePawn(to: .queen)
        XCTAssertEqual(game.board[.a8], Piece(color: .white, type: .queen))
        XCTAssertEqual(game.fen, "Q7/7k/8/8/8/8/8/P6K b KQk - 0 0")
    }

    func testPiecesMovesAndCastling() {
        let game = ClassicGame(board: Board())
        game.movePiece(fromPosition: .d2, toPosition: .d4)
        game.movePiece(fromPosition: .d7, toPosition: .d5)

        game.movePiece(fromPosition: .e2, toPosition: .e4)
        game.movePiece(fromPosition: .e7, toPosition: .e5)

        game.movePiece(fromPosition: .g1, toPosition: .f3)
        game.movePiece(fromPosition: .b8, toPosition: .c6)

        game.movePiece(fromPosition: .f1, toPosition: .b5)
        game.movePiece(fromPosition: .c8, toPosition: .g4)

        game.movePiece(fromPosition: .d1, toPosition: .d3)
        game.movePiece(fromPosition: .d8, toPosition: .h4)

        game.movePiece(fromPosition: .f1, toPosition: .b5)
        game.movePiece(fromPosition: .c1, toPosition: .g4)

        game.movePiece(fromPosition: .e1, toPosition: .g1)
        game.movePiece(fromPosition: .e8, toPosition: .c8)

        XCTAssertEqual(
            game.fen,
            "2kr1bnr/ppp2ppp/2n5/1B1pp3/3PP1bq/3Q1N2/PPP2PPP/RNB2RK1 w - - 0 0"
        )
    }

    func testGameStatesAndUndoMoves() {
        let game = ClassicGame(fromFen: "7k/8/7K/6Q1/8/8/8/8 w KQkq - 0 0")
        XCTAssertEqual(game.state, .inProgress)

        game.movePiece(fromPosition: .g5, toPosition: .g6)
        XCTAssertEqual(game.state, .stalemate(color: .black))

        game.undoLastMove()
        game.movePiece(fromPosition: .g5, toPosition: .g7)
        XCTAssertEqual(game.state, .checkmate(color: .black))
    }

    func testIsKingInCheck() {
        let game = ClassicGame(fromFen: "7k/8/7K/6Q1/8/8/8/8 w KQkq - 0 0")
        XCTAssertFalse(game.isKingInCheck(forColor: .black))
        game.movePiece(fromPosition: .g5, toPosition: .e5)
        XCTAssertTrue(game.isKingInCheck(forColor: .black))
    }
}
