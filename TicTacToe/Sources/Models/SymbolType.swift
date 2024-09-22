enum Symbol: Hashable, CaseIterable, CustomStringConvertible {
    case circle
    case cross

    /// 「O」を先攻とする文化圏は日本だけ
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
