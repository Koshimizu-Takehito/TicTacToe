import AppIntents
import WidgetKit

// MARK: - WidgetConfigurationIntent

struct WidgetConfigurationIntent: AppIntents.WidgetConfigurationIntent {
    static let title: LocalizedStringResource = "Select Widget Configuration"

    @Parameter(title: "Color Scheme")
    var colorScheme: ColorSchemeEntity?

    @Parameter(title: "Color Palette")
    var colorPalette: ColorPaletteEntity?

    init(colorPalette: ColorPaletteEntity, colorScheme: ColorSchemeEntity) {
        self.colorPalette = colorPalette
        self.colorScheme = colorScheme
    }

    init() {
        self.init(
            colorPalette: .init(id: .default),
            colorScheme: .init(id: .default)
        )
    }
}
