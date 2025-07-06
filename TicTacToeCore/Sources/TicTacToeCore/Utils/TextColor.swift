import SwiftUI

/// Property wrapper that provides an appropriate foreground color for text.
@propertyWrapper
struct TextColor: DynamicProperty {
    /// Current color scheme.
    @Environment(\.colorScheme) private var colorScheme
    /// Default line color.
    @Environment(\.colorPalette.foreground) private var foregroundColor
    /// Color used for the circle symbol.
    @Environment(\.colorPalette.symbol1) private var symbolColor

    var wrappedValue: Color {
        // Use the circle symbol color in dark mode and the line color in light mode.
        switch colorScheme {
        case .dark:
            return symbolColor
        default:
            return foregroundColor
        }
    }
}
