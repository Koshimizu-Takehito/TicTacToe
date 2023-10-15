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
}
