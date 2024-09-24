import Observation
import SwiftUI

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

#if os(watchOS)
extension PlayerMenuViewModel {
    var difficulty: Difficulty {
        get {
            switch gameBoard.role2 {
            case let .computer(difficulty):
                return difficulty
            default:
                return .medium
            }
        }
        set {
            gameBoard.role2 = .computer(newValue)
        }
    }
}
#endif

extension PlayerMenuIconViewModel {
    convenience init(viewModel: PlayerMenuViewModel, player: Player) {
        self.init(gameBoard: viewModel.gameBoard, player: player)
    }
}
