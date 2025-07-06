enum Symbol: Hashable, CaseIterable, CustomStringConvertible {
    case circle
    case cross

    /// Default symbol for the first player.
    /// In most locales X starts first; only a few cultures such as Japan use O.
    static var `default`: Self {
        switch LanguageCode.current {
        case .ja, .ain:
            return .circle
        case _:
            return .cross
        }
    }

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
