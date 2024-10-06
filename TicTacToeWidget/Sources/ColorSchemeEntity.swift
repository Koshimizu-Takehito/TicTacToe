import AppIntents

// MARK: - ColorSchemeEntity

struct ColorSchemeEntity: AppIntents.AppEntity {
    static let typeDisplayRepresentation: TypeDisplayRepresentation = "Color Scheme"
    static let defaultQuery = ColorSchemeQuery()

    let id: ColorSchemeEntitySelection

    var displayRepresentation: DisplayRepresentation {
        switch id {
        case .default:
            "Default"
        case .light:
            "Light"
        case .dark:
            "Dark"
        }
    }

    static let allCases: [ColorSchemeEntity] = ColorSchemeEntitySelection
        .allCases
        .map(ColorSchemeEntity.init(id:))
}

// MARK: - ColorSchemeEntitySelection

enum ColorSchemeEntitySelection: String, CaseIterable, EntityIdentifierConvertible {
    case `default`
    case light
    case dark

    var entityIdentifierString: String {
        rawValue
    }

    static func entityIdentifier(for entityIdentifierString: String) -> Self? {
        self.init(rawValue: entityIdentifierString)
    }
}

// MARK: - ColorSchemeQuery

struct ColorSchemeQuery: AppIntents.EntityQuery {
    func entities(for identifiers: [ColorSchemeEntity.ID]) async throws -> [ColorSchemeEntity] {
        ColorSchemeEntity.allCases.filter { identifiers.contains($0.id) }
    }

    func suggestedEntities() async throws -> [ColorSchemeEntity] {
        ColorSchemeEntity.allCases
    }

    func defaultResult() async -> ColorSchemeEntity? {
        ColorSchemeEntity(id: .default)
    }
}
