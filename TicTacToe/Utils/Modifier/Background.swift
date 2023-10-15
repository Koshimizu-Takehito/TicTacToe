import SwiftUI

/// 背景
struct Background: ViewModifier {
    @Environment(\.colorPalette.background) var color

    func body(content: Content) -> some View {
        content
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(in: Rectangle())
            .backgroundStyle(color)
            .ignoresSafeArea()
    }
}
