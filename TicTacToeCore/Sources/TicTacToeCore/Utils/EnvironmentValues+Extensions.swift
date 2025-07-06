import SwiftUI

extension EnvironmentValues {
    // MARK: - Layout

    /// Width of the symbol strokes.
    @Entry var symbolLineWidth: Double = 6.0
    /// Spacing between lattice lines.
    @Entry var latticeSpacing: Double = 6.0

    // MARK: - Colors

    /// Active color palette.
    @Entry var colorPalette: ColorPalette = .default
}
