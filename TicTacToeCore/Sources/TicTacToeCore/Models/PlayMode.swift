import SwiftUI

// MARK: - Difficulty

enum Difficulty: Hashable, CaseIterable {
    case easy
    case medium
    case hard

    var title: String {
        switch self {
        case .easy:
            String(localized: "Easy", bundle: .module)
        case .medium:
            String(localized: "Medium", bundle: .module)
        case .hard:
            String(localized: "Hard", bundle: .module)
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
    case computer(Difficulty = .medium)
}

extension PlayMode: CaseIterable {
    static let allCases: [Self] = [
        .player,
        .random,
        .computer(.easy),
        .computer(.medium),
        .computer(.hard),
    ]

    static let longTitle: Self = {
        let longTitle = PlayMode.allCases.max { lhs, rhs in
            let lhs = lhs.difficulty ?? lhs.title
            let rhs = rhs.difficulty ?? rhs.title
            return lhs.count <= rhs.count
        }
        return longTitle ?? .player
    }()
}

extension PlayMode {
    var title: String {
        switch self {
        case .player:
            String(localized: "Player", bundle: .module)
        case .random:
            String(localized: "Random", bundle: .module)
        case .computer:
            String(localized: "Computer", bundle: .module)
        }
    }

    var difficulty: String? {
        switch self {
        case .player, .random:
            nil
        case let .computer(difficulty):
            difficulty.title
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
