import SwiftUI

public struct TicTacToeView: View {
    @State private var colorPalette: ColorPalette = .default
    @State private var colorScheme: ColorScheme?

    public init() {}

    public var body: some View {
        GameBoardView()
            .modifier(GameBoardModifier(
                gameBoard: GameBoard(),
                colorPalette: colorPalette,
                colorScheme: colorScheme
            ))
            .onOpenURL { url in
                if let newPalette = url.colorPalette, colorPalette.name != newPalette.name {
                    colorPalette = newPalette
                }
                if let newScheme = url.colorScheme, colorScheme != newScheme {
                    colorScheme = newScheme
                }
            }
    }
}

#Preview {
    TicTacToeView()
}
