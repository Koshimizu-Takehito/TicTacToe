import SwiftUI

// MARK: - GameBoardModifier

struct GameBoardModifier: ViewModifier {
    let board: GameBoard

    func body(content: Content) -> some View {
        content
            .environment(board)
            .environment(PlayerMenuViewModel(gameBoard: board))
            .environment(GameBoardViewModel(gameBoard: board))
    }
}

// MARK: -

extension View {
    func environment(gameBoard: GameBoard = GameBoard()) -> some View {
        modifier(GameBoardModifier(board: gameBoard))
    }
}
