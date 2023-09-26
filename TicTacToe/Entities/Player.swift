//
//  Player.swift
//  TicTacToe
//
//  Created by Takehito Koshimizu on 2023/09/24.
//

enum Player: Hashable {
    case player1
    case player2

    var check: MarkType {
        switch self {
        case .player1:
            return .circle
        case .player2:
            return .cross
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
