//
//  Timer.swift
//  Chessy
//
//  Created by Yasha Serhiienko on 23.07.2023.
//

import Foundation

protocol GameTimerDelegate: AnyObject {
    func didUpdateTime(with time: Int, for color: PieceColor)

    var turn: PieceColor { get }
    var state: GameState { get }
}

class GameTimer {
    private var whiteTime: Int
    private var blackTime: Int

    private var timer = Timer()
    private var activeColor: PieceColor
    private var isStarted = false

    weak var delegate: GameTimerDelegate?

    var whiteMinutes: Int { whiteTime / 600 }
    var whiteSeconds: Int { whiteTime / 10 }

    var blackMinutes: Int { blackTime / 600 }
    var blackSeconds: Int { blackTime / 10 }

    init(seconds: Int) {
        self.whiteTime = seconds * 10
        self.blackTime = seconds * 10
        activeColor = .white
    }

    func set(seconds: Int, for color: PieceColor) {
        if color == .white {
            whiteTime = seconds * 10
        } else {
            blackTime = seconds * 10
        }
    }

    func add(seconds: Int, for color: PieceColor) {
        if color == .white {
            whiteTime += seconds * 10
            delegate?.didUpdateTime(with: whiteTime, for: color)
        } else {
            blackTime += seconds * 10
            delegate?.didUpdateTime(with: blackTime, for: color)
        }
    }

    func start() {
        guard !isStarted, delegate?.state == .inProgress else { return }

        isStarted = true
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            switch self?.delegate?.turn {
            case .white:
                if self?.whiteTime ?? 0 > 0 {
                    self?.update(for: .white)
                } else {
                    self?.timer.invalidate()
                    self?.isStarted = false
                }
            case .black:
                if self?.blackTime ?? 0 > 0 {
                    self?.update(for: .black)
                } else {
                    self?.timer.invalidate()
                    self?.isStarted = false
                }
            case .none:
                return
            }
        }
    }

    func update(for color: PieceColor) {
        switch color {
        case .white:
            whiteTime -= 1
            delegate?.didUpdateTime(with: whiteTime, for: color)
        case .black:
            blackTime -= 1
            delegate?.didUpdateTime(with: blackTime, for: color)
        }
    }

    func stop() {
        isStarted = false
        timer.invalidate()
    }
}
