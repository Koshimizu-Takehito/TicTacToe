import SwiftUI

// MARK: - GameBoardModifier

struct GameBoardModifier: ViewModifier {
    let gameBoard: GameBoard

    func body(content: Content) -> some View {
        content
            .environment(gameBoard)
            .environment(PlayerMenuViewModel(gameBoard: gameBoard))
            .environment(GameBoardViewModel(gameBoard: gameBoard))
    }
}

// MARK: -

extension View {
    func myEnvironment(gameBoard: GameBoard = GameBoard()) -> some View {
        modifier(GameBoardModifier(gameBoard: gameBoard))
    }
}
