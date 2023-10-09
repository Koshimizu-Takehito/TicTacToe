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
    private struct ForegroundKey: EnvironmentKey {
        static let defaultValue: Color = .foreground
    }

    var foreground: Color {
        get { self[ForegroundKey.self] }
        set { self[ForegroundKey.self] = newValue }
    }

    private struct BackgroundKey: EnvironmentKey {
        static let defaultValue: Color = .background
    }

    var background: Color {
        get { self[BackgroundKey.self] }
        set { self[BackgroundKey.self] = newValue }
    }

    private struct MarkColor1Key: EnvironmentKey {
        static let defaultValue: Color = .check1
    }

    var symbolColor1: Color {
        get { self[MarkColor1Key.self] }
        set { self[MarkColor1Key.self] = newValue }
    }

    private struct MarkColor2Key: EnvironmentKey {
        static let defaultValue: Color = .check2
    }

    var symbolColor2: Color {
        get { self[MarkColor2Key.self] }
        set { self[MarkColor2Key.self] = newValue }
    }
}
