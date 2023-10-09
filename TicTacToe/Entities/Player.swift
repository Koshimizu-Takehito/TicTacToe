enum Player: Hashable, CaseIterable {
    case player1
    case player2

    var symbol: SymbolType {
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
