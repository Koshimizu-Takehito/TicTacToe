enum Player: Hashable, CaseIterable {
    /// 先手
    case first
    /// 後手
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
