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
}
