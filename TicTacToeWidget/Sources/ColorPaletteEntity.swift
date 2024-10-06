import AppIntents
import TicTacToeWidgetCore

// MARK: - ColorPaletteEntity

struct ColorPaletteEntity: AppIntents.AppEntity {
    static let typeDisplayRepresentation: TypeDisplayRepresentation = "Color Palette"
    static let defaultQuery = ColorPaletteQuery()

    let id: ColorPalette.Name

    var displayRepresentation: DisplayRepresentation {
        switch id {
        case .default:
            "Default"
        case .apricot:
            "Apricot"
        case .astra:
            "Astra"
        case .brandyPunch:
            "Brandy Punch"
        case .carnation:
            "Carnation"
        case .carouselPink:
            "Carousel Pink"
        case .ceriseRed:
            "Cerise Red"
        case .contessa:
            "Contessa"
        case .emerald:
            "Emerald"
        case .froly:
            "Froly"
        case .funBlue:
            "Fun Blue"
        case .fuzzyWuzzyBrown:
            "Fuzzy Wuzzy Brown"
        case .gableGreen:
            "Gable Green"
        case .hitPink:
            "Hit Pink"
        case .java:
            "Java"
        case .lima:
            "Lima"
        case .lochmara:
            "Lochmara"
        case .mauve:
            "Mauve"
        case .mulberry:
            "Mulberry"
        case .ochre:
            "Ochre"
        case .persianGreen:
            "Persian Green"
        case .redDamask:
            "Red Damask"
        case .revolver:
            "Revolver"
        case .rodeoDust:
            "Rodeo Dust"
        case .roman:
            "Roman"
        case .romanCoffee:
            "Roman Coffee"
        case .royalPurple:
            "Royal Purple"
        case .schoolBusYellow:
            "School Bus Yellow"
        case .shipGrayLightShade:
            "Ship Gray Light Shade"
        case .trueV:
            "True V"
        case .wattle:
            "Wattle"
        case .whiskey:
            "Whiskey"
        }
    }

    static let allCases: [ColorPaletteEntity] = ColorPalette.Name
        .allCases
        .map(ColorPaletteEntity.init(id:))
}

// MARK: - ColorPaletteQuery

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
