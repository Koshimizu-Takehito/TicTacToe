import SwiftUI

enum PlayerMode: Hashable, CaseIterable {
    case player
    case random
    case computer

    var title: String {
        switch self {
        case .player:
            "Player"
        case .random:
            "Random"
        case .computer:
            "Computer"
        }
    }

    var systemImage: String {
        switch self {
        case .player:
            "person.fill"
        case .random:
            "dice"
        case .computer:
            "x.squareroot"
        }
    }
}
