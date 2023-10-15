import SwiftUI

// MARK: - ColorPalette
struct ColorPalette: Hashable {
    let background: ColorCode
    let foreground: ColorCode
    let check1: ColorCode
    let check2: ColorCode
}

extension ColorPalette {
    static let `default` = ColorPalette(
        background: 0x12BDAC,
        foreground: 0x12A192,
        check1: 0xF4EBD3,
        check2: 0x545454
    )

    static let java = ColorPalette(
        background: 0x28B9B8,
        foreground: 0x089D9C,
        check1: 0xF4EBD3,
        check2: 0x0849A5
    )

    static let lochmara = ColorPalette(
        background: 0x3881D5,
        foreground: 0x135FBE,
        check1: 0xF4EBD3,
        check2: 0x54DDDC
    )

    static let fuzzyWuzzyBrown = ColorPalette(
        background: 0xBD4155,
        foreground: 0x901D2C,
        check1: 0xF4EBD3,
        check2: 0xE7896A
    )

    static let apricot = ColorPalette(
        background: 0xE7896A,
        foreground: 0xB34F34,
        check1: 0xF4EBD3,
        check2: 0x901D2C
    )

    static let brandyPunch = ColorPalette(
        background: 0xC28233,
        foreground: 0x8C4B09,
        check1: 0xF4EBD3,
        check2: 0xFDDC03
    )

    static let schoolBusYellow = ColorPalette(
        background: 0xFDDC03,
        foreground: 0xAD9300,
        check1: 0xF4EBD3,
        check2: 0x8C4B09
    )

    static let wattle = ColorPalette(
        background: 0xB0B637,
        foreground: 0x8E9516,
        check1: 0xF4EBD3,
        check2: 0x08171C
    )

    static let bunkerLightShade = ColorPalette(
        background: 0x08171C,
        foreground: 0xDFE56E,
        check1: 0xF4EBD3,
        check2: 0xB0B637
    )

    static let trueV = ColorPalette(
        background: 0x8C84EC,
        foreground: 0x554AC2,
        check1: 0xF4EBD3,
        check2: 0x52E0DE
    )

    static let romanCoffee = ColorPalette(
        background: 0x715241,
        foreground: 0x533629,
        check1: 0xF4EBD3,
        check2: 0xC07549
    )

    static let whiskey = ColorPalette(
        background: 0xD89265,
        foreground: 0xA35933,
        check1: 0xF4EBD3,
        check2: 0x533629
    )

    static let ochre = ColorPalette(
        background: 0xD97D27,
        foreground: 0x9F4907,
        check1: 0xF4EBD3,
        check2: 0xD2B3C6
    )

    static let carouselPink = ColorPalette(
        background: 0xD2B3C6,
        foreground: 0xB28BA3,
        check1: 0xF4EBD3,
        check2: 0x9F4907
    )
}
