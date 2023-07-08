//
//  ChessyTests.swift
//  ChessyTests
//
//  Created by Yasha Serhiienko on 05.07.2023.
//

import XCTest
@testable import Chessy

final class ChessyTests: XCTestCase {

    func testPawnMove() {
        let board1 = Board()

        XCTAssertTrue(board1.canMove(fromPosition: .b2, toPosition: .b4))
        XCTAssertTrue(board1.canMove(fromPosition: .b2, toPosition: .b3))
        XCTAssertFalse(board1.canMove(fromPosition: .b2, toPosition: .b5))
        XCTAssertFalse(board1.canMove(fromPosition: .b2, toPosition: .a3))
        XCTAssertFalse(board1.canMove(fromPosition: .b2, toPosition: .c3))
        XCTAssertFalse(board1.canMove(fromPosition: .b2, toPosition: .b2))
        XCTAssertFalse(board1.canMove(fromPosition: .b2, toPosition: .a4))
        XCTAssertFalse(board1.canMove(fromPosition: .b2, toPosition: .c4))
    }
    
    func testIfPiecesExistBetween() {
        let board = Board()

        XCTAssertFalse(board.piecesExistBetween(fromPosition: .a2, toPosition: .a4))
        XCTAssertFalse(board.piecesExistBetween(fromPosition: .a2, toPosition: .a7))
        XCTAssertFalse(board.piecesExistBetween(fromPosition: .a2, toPosition: .f7))
        
        XCTAssertTrue(board.piecesExistBetween(fromPosition: .a1, toPosition: .a4))
        XCTAssertTrue(board.piecesExistBetween(fromPosition: .a6, toPosition: .c8))
    }

}
