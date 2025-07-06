/// Represents either the first or second player.
enum Player: Hashable, CaseIterable {
    /// The player who moves first.
    case first
    /// The player who moves second.
    case second

    var symbol: Symbol {
        switch self {
        case .first:
            return .circle
        case .second:
            return .cross
        }
    }

    var opposite: Player {
        switch self {
        case .first:
            return .second
        case .second:
            return .first
        }
    }

    mutating func toggle() {
        self = opposite
    }
}
