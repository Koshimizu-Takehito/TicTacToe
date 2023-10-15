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

    static let ceriseRed = ColorPalette(
        background: 0xD83269,
        foreground: 0xA70835,
        check1: 0xF4EBD3,
        check2: 0x15B86B
    )

    static let emerald = ColorPalette(
        background: 0x059C51,
        foreground: 0x048240,
        check1: 0xF4EBD3,
        check2: 0xD83269
    )

    static let revolver = ColorPalette(
        background: 0x60375F,
        foreground: 0x361735,
        check1: 0xF4EBD3,
        check2: 0xD7868F
    )

    static let contessa = ColorPalette(
        background: 0xBB6770,
        foreground: 0x8D3F46,
        check1: 0xF4EBD3,
        check2: 0x3F1E3E
    )

    static let rodeoDust = ColorPalette(
        background: 0xA9927B,
        foreground: 0x8E755F,
        check1: 0xF4EBD3,
        check2: 0xBD4D2A
    )

    static let redDamask = ColorPalette(
        background: 0xF1865D,
        foreground: 0xBD4D2A,
        check1: 0xF4EBD3,
        check2: 0x8E755F
    )

    static let mauve = ColorPalette(
        background: 0xC7A3FD,
        foreground: 0x8F5ACD,
        check1: 0xF4EBD3,
        check2: 0xB6A162
    )

    static let astra = ColorPalette(
        background: 0xD5C38B,
        foreground: 0xB6A162,
        check1: 0xF4EBD3,
        check2: 0x8F5ACD
    )

    static let shipGrayLightShade = ColorPalette(
        background: 0x584D5B,
        foreground: 0x372F3C,
        check1: 0xF4EBD3,
        check2: 0xBEBDC7
    )

    static let bonJour = ColorPalette(
        background: 0x584D5B,
        foreground: 0x372F3C,
        check1: 0xF4EBD3,
        check2: 0xBEBDC7
    )

    static let haitiLightShade = ColorPalette(
        background: 0x581256,
        foreground: 0xD7669F,
        check1: 0xF4EBD3,
        check2: 0xBE4880
    )

    static let mulberry = ColorPalette(
        background: 0xBE4880,
        foreground: 0x912251,
        check1: 0xF4EBD3,
        check2: 0x31073A
    )

    static let funBlue = ColorPalette(
        background: 0x298CD4,
        foreground: 0x004891,
        check1: 0xF4EBD3,
        check2: 0xFE7588
    )

    static let carnation = ColorPalette(
        background: 0xF74C61,
        foreground: 0xC60418,
        check1: 0xF4EBD3,
        check2: 0x004891
    )

    static let royalPurple = ColorPalette(
        background: 0x9F69D4,
        foreground: 0x521F83,
        check1: 0xF4EBD3,
        check2: 0x34BFBA
    )

    static let persianGreen = ColorPalette(
        background: 0x34BFBA,
        foreground: 0x01706B,
        check1: 0xF4EBD3,
        check2: 0x9F69D4
    )

    static let roman = ColorPalette(
        background: 0xFA8276,
        foreground: 0xAF322A,
        check1: 0xF4EBD3,
        check2: 0xDCB229
    )

    static let lima = ColorPalette(
        background: 0x5FBB2A,
        foreground: 0x2F8307,
        check1: 0xF4EBD3,
        check2: 0x203B34
    )

    static let gableGreen = ColorPalette(
        background: 0x40615B,
        foreground: 0x173029,
        check1: 0xF4EBD3,
        check2: 0x86DE4D
    )

    static let hitPink = ColorPalette(
        background: 0xF7B086,
        foreground: 0xC26A40,
        check1: 0xF4EBD3,
        check2: 0xDD4859
    )

    static let froly = ColorPalette(
        background: 0xFE92A0,
        foreground: 0xDD4859,
        check1: 0xF4EBD3,
        check2: 0xC26A40
    )
}
