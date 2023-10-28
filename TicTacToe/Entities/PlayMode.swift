import SwiftUI

// MARK: - Difficulty
enum Difficulty: Hashable, CaseIterable {
    case easy
    case medium
    case hard

    var title: String {
        switch self {
        case .easy:
            "Easy"
        case .medium:
            "Medium"
        case .hard:
            "Hard"
        }
    }

    var systemImage: String {
        switch self {
        case .easy:
            "1.square.fill"
        case .medium:
            "2.square.fill"
        case .hard:
            "3.square.fill"
        }
    }

    var level: Int {
        switch self {
        case .easy:
            1
        case .medium:
            2
        case .hard:
            3
        }
    }
}

// MARK: - PlayMode
enum PlayMode: Hashable {
    case player
    case random
    case computer(Difficulty)
}

extension PlayMode: CaseIterable {
    static var allCases: [Self] = [
        .player,
        .random,
        .computer(.easy),
        .computer(.medium),
        .computer(.hard),
    ]
}

extension PlayMode {
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
