import SwiftUI

extension EnvironmentValues {
    private struct MarkLineWidthKey: EnvironmentKey {
        static let defaultValue: Double = 6.0
    }

    var symbolLineWidth: Double {
        get { self[MarkLineWidthKey.self] }
        set { self[MarkLineWidthKey.self] = newValue }
    }

    private struct LatticeSpacingKey: EnvironmentKey {
        static var defaultValue: Double = 6.0
    }

    var latticeSpacing: Double {
        get { self[LatticeSpacingKey.self] }
        set { self[LatticeSpacingKey.self] = newValue }
    }
}

extension EnvironmentValues {
    private struct ColorPaletteKey: EnvironmentKey {
        static let defaultValue: ColorPalette = .carouselPink
    }

    var colorPalette: ColorPalette {
        get { self[ColorPaletteKey.self] }
        set { self[ColorPaletteKey.self] = newValue }
    }
}
