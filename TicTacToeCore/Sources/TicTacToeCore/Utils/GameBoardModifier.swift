import SwiftUI

// MARK: - GameBoardModifier

struct GameBoardModifier: ViewModifier {
    let gameBoard: GameBoard
    let playerMenuViewModel: PlayerMenuViewModel
    let gameBoardViewModel: GameBoardViewModel

    func body(content: Content) -> some View {
        content
            .environment(gameBoard)
            .environment(playerMenuViewModel)
            .environment(gameBoardViewModel)
    }
}

extension GameBoardModifier {
    init(
        gameBoard: GameBoard = .init(),
        colorPalette: ColorPalette = .default,
        colorScheme: ColorScheme = .light
    ) {
        self.init(
            gameBoard: gameBoard,
            playerMenuViewModel: PlayerMenuViewModel(
                gameBoard: gameBoard
            ),
            gameBoardViewModel: GameBoardViewModel(
                gameBoard: gameBoard,
                colorPalette: colorPalette,
                colorScheme: colorScheme
            )
        )
    }

    init(viewModel: GameBoardViewModel) {
        let gameBoard = viewModel.gameBoard
        self.init(
            gameBoard: gameBoard,
            playerMenuViewModel: .init(gameBoard: gameBoard),
            gameBoardViewModel: viewModel
        )
    }
}
