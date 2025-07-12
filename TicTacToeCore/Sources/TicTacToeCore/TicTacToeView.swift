import SwiftUI

public struct TicTacToeView: View {
    @State private var viewModel = GameBoardViewModel()
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    public init() {}

    public var body: some View {
        GameBoardView()
            .modifier(GameBoardModifier(viewModel: viewModel))
            .onChange(of: colorScheme, initial: true) { _, newScheme in
                viewModel.colorScheme = newScheme
            }
            .onChange(of: reduceMotion, initial: true) { _, newValue in
                viewModel.reduceMotion = newValue
            }
            .onOpenURL {
                viewModel.recieve(url: $0)
            }
    }
}

#Preview {
    TicTacToeView()
}
