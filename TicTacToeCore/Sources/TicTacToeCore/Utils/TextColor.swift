import SwiftUI

/// テキストの色
@propertyWrapper
struct TextColor: DynamicProperty {
    /// カラースキーム
    @Environment(\.colorScheme) private var colorScheme
    /// 線の色
    @Environment(\.colorPalette.foreground) private var foregroundColor
    /// 記号『◯』の色
    @Environment(\.colorPalette.symbol1) private var symbolColor

    var wrappedValue: Color {
        // ダークテーマの場合は、記号『◯』と同じ色
        // ライトテーマの場合は、線と同じ色
        switch colorScheme {
        case .dark:
            return symbolColor
        default:
            return foregroundColor
        }
    }
}
