enum Symbol: Hashable, CaseIterable, CustomStringConvertible {
    case circle
    case cross

    var opposite: Self {
        switch self {
        case .circle:
            return .cross
        case .cross:
            return .circle
        }
    }

    mutating func toggle() {
        self = opposite
    }

    var description: String {
        switch self {
        case .circle:
            return "◯"
        case .cross:
            return "✕"
        }
    }
}
