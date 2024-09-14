//
//  PlayerMenuIconViewModel.swift
//  TicTacToe
//
//  Created by Takehito Koshimizu on 2024/09/14.
//

import SwiftUI
import Observation

@MainActor
@Observable
final class PlayerMenuIconViewModel {
    private let gameBoard: GameBoard
    private let player: Player

    var mode: PlayMode {
        player == .first ? gameBoard.role1 : gameBoard.role2
    }

    var symbol: Symbol {
        gameBoard.symbols[player]
    }

    init(gameBoard: GameBoard, player: Player) {
        self.gameBoard = gameBoard
        self.player = player
    }
}
