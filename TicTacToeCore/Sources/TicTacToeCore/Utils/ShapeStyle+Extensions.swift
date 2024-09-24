import SwiftUI

extension ShapeStyle where Resolved == Color.Resolved {
    func screen<C: ShapeStyle>(_ rhs: C) -> some ShapeStyle where C.Resolved == Color.Resolved {
        ScreenStyle(self, rhs)
    }
}

private struct ScreenStyle<C1: ShapeStyle, C2: ShapeStyle>: ShapeStyle where C1.Resolved == Color.Resolved, C2.Resolved == Color.Resolved {
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

extension ShapeStyle where Self == Color {
    static var systemGroupedBackground: Self {
        Self.systemGroupedBackground
    }
}

extension Color {
    static var systemGroupedBackground: Color {
        #if os(iOS)
            return Color(UIColor.systemGroupedBackground)
        #elseif os(macOS)
            return Color(NSColor.windowBackgroundColor)
        #else
            return Color.clear
        #endif
    }
}
