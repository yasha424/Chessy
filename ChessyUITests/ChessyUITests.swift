//
//  ChessyUITests.swift
//  ChessyUITests
//
//  Created by Yasha Serhiienko on 05.07.2023.
//

import XCTest

final class ChessyUITests: XCTestCase {

    private var app: XCUIApplication!

    override func setUpWithError() throws {
        app = XCUIApplication()
        app.launch()
    }

    override func tearDownWithError() throws {
        app = nil
    }

    func testDragGestureMove() {
        app.otherElements["a2"].tap()
        let a4 = app.otherElements["a4"]
        a4.tap()
//        let board = Board(fromFen: "rnbqkbnr/pppppppp/8/8/P7/8/1PPPPPPP/RNBQKBNR w KQkq - 0 1")
        XCTAssertTrue(a4.images["white_pawn"].exists)
    }
}
