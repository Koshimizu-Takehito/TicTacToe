import SwiftUI

// MARK: - ColorCode
struct ColorCode: Hashable {
    var hex: Int

    var red: Double   { .init(hex >> 16 & 0xFF)/0xFF }
    var green: Double { .init(hex >>  8 & 0xFF)/0xFF }
    var blue: Double  { .init(hex >>  0 & 0xFF)/0xFF }
}

extension ColorCode: ShapeStyle {
    func resolve(in environment: EnvironmentValues) -> Color.Resolved {
        .init(red: Float(red), green: Float(green), blue: Float(blue))
    }
}

extension ColorCode: CustomStringConvertible, ExpressibleByIntegerLiteral {
    init(_ hex: Int) {
        self.init(hex: hex)
    }

    init(integerLiteral value: Int) {
        self.init(value)
    }

    var description: String {
        String(hex, radix: 16, uppercase: true)
    }
}

extension Color {
    init(_ code: ColorCode) {
        self.init(red: Double.init(code.red), green: Double.init(code.green), blue: Double.init(code.blue))
    }
}

struct ScreenStyle<C1: ShapeStyle, C2: ShapeStyle>: ShapeStyle where C1.Resolved == Color.Resolved, C2.Resolved == Color.Resolved {
    private let color1: C1
    private let color2: C2

    init(_ color1: C1, _ color2: C2) {
        self.color1 = color1
        self.color2 = color2
    }

    func resolve(in environment: EnvironmentValues) -> Color.Resolved {
        func screen(_ c1: Float, _ c2: Float) -> Float {
            1 - ((1 - c1) * (1 - c2))
        }
        let r1 = color1.resolve(in: environment)
        let r2 = color2.resolve(in: environment)
        return .init(
            red: screen(r1.red, r2.red),
            green: screen(r1.green, r2.green),
            blue: screen(r1.blue, r2.blue)
        )
    }
}
