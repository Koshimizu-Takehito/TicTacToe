import SwiftUI

extension Color {
    static let background = Color(red: 18/255, green: 189/255, blue: 172/255)
    static let foreground = Color(red: 18/255, green: 161/255, blue: 146/255)
    static let check1 = Color(red: 244/255, green: 235/255, blue: 211/255)
    static let check2 = Color(red: 84/255, green: 84/255, blue: 84/255)
}

extension Color {
    static func screen(environment e: EnvironmentValues, _ c1: Self, _ c2: Self) -> Self {
        Color(Color.Resolved.screen(c1.resolve(in: e), c2.resolve(in: e)))
    }
}

extension Color.Resolved {
    static func screen(_ color1: Self, _ color2: Self) -> Self {
        func value(_ color1: Self, _ color2: Self, _ keyPath: KeyPath<Self, Float>) -> Float {
            1 - ((1 - color1[keyPath: keyPath]) * (1 - color2[keyPath: keyPath]))
        }
        return .init(
            red: value(color1, color2, \.red),
            green: value(color1, color2, \.green),
            blue: value(color1, color2, \.blue)
        )
    }
}
