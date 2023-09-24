//
//  Player.swift
//  TicTacToe
//
//  Created by Takehito Koshimizu on 2023/09/24.
//

enum Player: Hashable {
    case player1
    case player2

    var check: Check {
        switch self {
        case .player1:
            return .check1
        case .player2:
            return .check2
        }
    }

    mutating func toggle() {
        switch self {
        case .player1:
            self = .player2
        case .player2:
            self = .player1
        }
    }
}
