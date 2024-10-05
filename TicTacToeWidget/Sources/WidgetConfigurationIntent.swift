import AppIntents
import TicTacToeWidgetCore
import WidgetKit

struct WidgetConfigurationIntent: AppIntents.WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "Select Color Palette"
    static var description = IntentDescription("Selects the Color Palette.")

    @Parameter(title: "Color Palette")
    var colorPalette: AppEntity?

    init(character: AppEntity) {
        colorPalette = character
    }

    init() {
        colorPalette = .init(id: .default)
    }
}

struct AppEntity: AppIntents.AppEntity {
    static let typeDisplayRepresentation: TypeDisplayRepresentation = "Color Palette"
    static let defaultQuery = EntityQuery()

    let id: ColorPalette.Name

    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "\(id.description)")
    }

    static let allCases: [AppEntity] = ColorPalette.Name
        .allCases
        .map(AppEntity.init(id:))
}

struct EntityQuery: AppIntents.EntityQuery {
    func entities(for identifiers: [AppEntity.ID]) async throws -> [AppEntity] {
        AppEntity.allCases.filter { identifiers.contains($0.id) }
    }

    func suggestedEntities() async throws -> [AppEntity] {
        AppEntity.allCases
    }

    func defaultResult() async -> AppEntity? {
        AppEntity(id: .default)
    }
}
