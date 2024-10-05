import SwiftUI

// MARK: - GameBoardModifier

struct GameBoardModifier: ViewModifier {
    let gameBoard: GameBoard
    let colorPalette: ColorPalette
    let colorScheme: ColorScheme?

    init(gameBoard: GameBoard = .init(), colorPalette: ColorPalette = .default, colorScheme: ColorScheme? = nil) {
        self.gameBoard = gameBoard
        self.colorPalette = colorPalette
        self.colorScheme = colorScheme
    }

    func body(content: Content) -> some View {
        content
            .environment(gameBoard)
            .environment(PlayerMenuViewModel(gameBoard: gameBoard))
            .environment(GameBoardViewModel(gameBoard: gameBoard, colorPalette: colorPalette, colorScheme: colorScheme))
    }
}
