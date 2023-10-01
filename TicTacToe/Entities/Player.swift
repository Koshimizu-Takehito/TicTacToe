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

    var opposite: Player {
        switch self {
        case .player1:
            return .player2
        case .player2:
            return .player1
        }
    }

    mutating func toggle() {
        self = opposite
    }
}
