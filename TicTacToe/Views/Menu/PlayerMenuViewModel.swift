import SwiftUI
import Observation

@MainActor
@Observable
final class PlayerMenuViewModel {
    fileprivate let gameBoard: GameBoard

    init(gameBoard: GameBoard) {
        self.gameBoard = gameBoard
    }

    func select(player: Player, role: PlayMode) {
        switch player {
        case .first:
            gameBoard.role1 = role
        case .second:
            gameBoard.role2 = role
        }
    }

    func toggle(symbol: Symbol, player: Player) {
        gameBoard.symbols[player] = symbol
        gameBoard.symbols[player.opposite] = symbol.opposite
    }
}

extension PlayerMenuIconViewModel {
    convenience init(viewModel: PlayerMenuViewModel, player: Player) {
        self.init(gameBoard: viewModel.gameBoard, player: player)
    }
}
