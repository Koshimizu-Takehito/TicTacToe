import SwiftUI

// MARK: - ColorPalette
struct ColorPalette: Hashable {
    var background: Color
    var foreground: Color
    var symbol1: Color
    var symbol2: Color

    init(name: ColorPalette.Name) {
        background = Color("\(Self.self)/\(name.rawValue)/background")
        foreground = Color("\(Self.self)/\(name.rawValue)/foreground")
        symbol1 = Color("\(Self.self)/\(name.rawValue)/symbol1")
        symbol2 = Color("\(Self.self)/\(name.rawValue)/symbol2")
    }
}

extension ColorPalette {
    static let `default` = Self.init(name: ColorPalette.Name.default)

    static let allCases: [Self] = ColorPalette.Name.allCases
        .map(Self.init(name:))
}

// MARK: - ColorPalette.Name
extension ColorPalette {
    enum Name: String, Hashable, CaseIterable {
        case `default`
        case apricot
        case astra
        case brandyPunch
        case bunkerLightShade
        case carnation
        case carouselPink
        case ceriseRed
        case contessa
        case emerald
        case froly
        case funBlue
        case fuzzyWuzzyBrown
        case gableGreen
        case haitiLightShade
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
