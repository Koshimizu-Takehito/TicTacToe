import SwiftUI

public struct TicTacToeView: View {
    @State private var viewModel = GameBoardViewModel()
    @Environment(\.colorScheme) private var colorScheme

    public init() {}

    public var body: some View {
        GameBoardView()
            .modifier(GameBoardModifier(viewModel: viewModel))
            .onChange(of: colorScheme, initial: true) { _, newScheme in
                viewModel.colorScheme = newScheme
            }
            .onOpenURL {
                viewModel.recieve(url: $0)
            }
    }
}

#Preview {
    TicTacToeView()
}
