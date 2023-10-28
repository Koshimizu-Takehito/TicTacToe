import SwiftUI

// MARK: - 幅・スペース
extension EnvironmentValues {
    /// シンボルの幅
    private struct SymbolLineWidthKey: EnvironmentKey {
        static let defaultValue: Double = 6.0
    }

    /// シンボルの幅
    var symbolLineWidth: Double {
        get { self[SymbolLineWidthKey.self] }
        set { self[SymbolLineWidthKey.self] = newValue }
    }

    /// 格子の幅
    private struct LatticeSpacingKey: EnvironmentKey {
        static var defaultValue: Double = 6.0
    }

    /// 格子の幅
    var latticeSpacing: Double {
        get { self[LatticeSpacingKey.self] }
        set { self[LatticeSpacingKey.self] = newValue }
    }
}

// MARK: - 色
extension EnvironmentValues {
    /// カラーパレット
    private struct ColorPaletteKey: EnvironmentKey {
        static let defaultValue: ColorPalette = .default
    }

    /// カラーパレット
    var colorPalette: ColorPalette {
        get { self[ColorPaletteKey.self] }
        set { self[ColorPaletteKey.self] = newValue }
    }
}

// MARK: - 設定
extension EnvironmentValues {
    /// 設定
    private struct PlayerSettingKey: EnvironmentKey {
        static let defaultValue: [Player: PlayerSetting] = [
            .first:  PlayerSetting(mode: .player, symbol: .circle),
            .second: PlayerSetting(mode: .computer(.medium), symbol: .cross),
        ]
    }

    /// 設定
    var playerSettings: [Player: PlayerSetting] {
        get { self[PlayerSettingKey.self] }
        set { self[PlayerSettingKey.self] = newValue }
    }
}

struct PlayerSetting {
    var mode: PlayMode
    var symbol: Symbol
}

struct PlayerSymbolSetting {
    var symbols: [Player: Symbol] = [
        .first: .circle,
        .second: .cross,
    ]

    func symbol(for player: Player) -> Symbol {
        self[player]
    }

    subscript(_ player: Player) -> Symbol {
        get { symbols[player]! }
        set { symbols[player] = newValue }
    }
}
