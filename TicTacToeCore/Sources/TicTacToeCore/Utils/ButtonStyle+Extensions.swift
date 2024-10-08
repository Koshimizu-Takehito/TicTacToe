import SwiftUI

// MARK: - TitleButtonStyle

extension ButtonStyle where Self == TitleButtonStyle {
    static var titleStyle: Self {
        TitleButtonStyle()
    }
}

// MARK: - ActionButtonStyle

extension ButtonStyle where Self == ActionButtonStyle {
    static var actionStyle: Self {
        ActionButtonStyle()
    }
}

// MARK: - TitleButtonStyle

struct TitleButtonStyle: ButtonStyle {
    @TextColor private var color

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.largeTitle.bold())
            .foregroundStyle(color)
            .padding(.horizontal)
            .opacity(configuration.isPressed ? 0.2 : 1)
    }
}

// MARK: - ActionButtonStyle

struct ActionButtonStyle: ButtonStyle {
    @TextColor private var color

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.title2.bold())
            .foregroundStyle(color)
            .padding(.horizontal)
            .opacity(configuration.isPressed ? 0.2 : 1)
            .padding()
    }
}
