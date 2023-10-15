import SwiftUI

struct TitleButtonStyle: ButtonStyle {
    @Environment(\.colorPalette.foreground) private var color

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.largeTitle.bold())
            .foregroundStyle(color)
            .padding(.horizontal)
            .opacity(configuration.isPressed ? 0.2 : 1)
            .padding()
    }
}

struct ActionButtonStyle: ButtonStyle {
    @Environment(\.colorPalette.foreground) private var color

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.title2.bold())
            .foregroundStyle(color)
            .padding(.horizontal)
            .opacity(configuration.isPressed ? 0.2 : 1)
            .padding()
    }
}
