import Foundation

enum GameState: Hashable {
    case ongoing
    case draw
    case win(Player, positions: [IndexPath])
}

extension GameState {
    var isGameFinished: Bool {
        switch self {
        case .win, .draw:
            return true
        case .ongoing:
            return false
        }
    }

    var winnerAndPositions: (winner: Player?, positions: [IndexPath]) {
        switch self {
        case .win(let winner, let positions):
            (winner, positions)
        case .ongoing, .draw:
            (nil, [])
        }
    }
}
