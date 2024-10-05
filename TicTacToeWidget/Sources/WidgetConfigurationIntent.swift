import AppIntents
import TicTacToeWidgetCore
import WidgetKit

struct WidgetConfigurationIntent: AppIntents.WidgetConfigurationIntent {
    static let title: LocalizedStringResource = "Select Widget Configuration"

    @Parameter(title: "Color Palette")
    var colorPalette: ColorPaletteEntity?

    init(character: ColorPaletteEntity) {
        colorPalette = character
    }
}

extension WidgetConfigurationIntent {
    init() {
        self.init(character: .init(id: .default))
    }
}

struct ColorPaletteEntity: AppIntents.AppEntity {
    static let typeDisplayRepresentation: TypeDisplayRepresentation = "Color Palette"
    static let defaultQuery = ColorPaletteQuery()

    let id: ColorPalette.Name

    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "\(id.description)")
    }

    static let allCases: [ColorPaletteEntity] = ColorPalette.Name
        .allCases
        .map(ColorPaletteEntity.init(id:))
}

struct ColorPaletteQuery: AppIntents.EntityQuery {
    func entities(for identifiers: [ColorPaletteEntity.ID]) async throws -> [ColorPaletteEntity] {
        ColorPaletteEntity.allCases.filter { identifiers.contains($0.id) }
    }

    func suggestedEntities() async throws -> [ColorPaletteEntity] {
        ColorPaletteEntity.allCases
    }

    func defaultResult() async -> ColorPaletteEntity? {
        ColorPaletteEntity(id: .default)
    }
}
