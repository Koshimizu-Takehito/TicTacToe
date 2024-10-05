import SwiftUI

// MARK: - ColorPalette

public struct ColorPalette: Hashable, Identifiable, Sendable {
    public var id = UUID()
    public var name: ColorPalette.Name
    public var background: Color
    public var foreground: Color
    public var symbol1: Color
    public var symbol2: Color

    public static let `default` = Self(name: ColorPalette.Name.default)

    public init(name: ColorPalette.Name) {
        self.name = name
        background = Color("\(Self.self)/\(name.rawValue)/background", bundle: .module)
        foreground = Color("\(Self.self)/\(name.rawValue)/foreground", bundle: .module)
        symbol1 = Color("\(Self.self)/\(name.rawValue)/symbol1", bundle: .module)
        symbol2 = Color("\(Self.self)/\(name.rawValue)/symbol2", bundle: .module)
    }
}

// MARK: - CaseIterable

extension ColorPalette: CaseIterable {
    public static let allCases: [Self] = ColorPalette.Name.allCases
        .map(Self.init(name:))
}

// MARK: - ColorPalette.Name

extension ColorPalette {
    public enum Name: String, Hashable, CaseIterable, Sendable {
        case `default`
        case apricot
        case astra
        case brandyPunch
        case carnation
        case carouselPink
        case ceriseRed
        case contessa
        case emerald
        case froly
        case funBlue
        case fuzzyWuzzyBrown
        case gableGreen
        case hitPink
        case java
        case lima
        case lochmara
        case mauve
        case mulberry
        case ochre
        case persianGreen
        case redDamask
        case revolver
        case rodeoDust
        case roman
        case romanCoffee
        case royalPurple
        case schoolBusYellow
        case shipGrayLightShade
        case trueV
        case wattle
        case whiskey
    }
}

extension ColorPalette.Name: CustomStringConvertible {
    public var description: String {
        rawValue
            .replacingOccurrences(of: "([A-Z])", with: " $1", options: .regularExpression)
            .capitalized
            .trimmingCharacters(in: .whitespaces)
    }
}
