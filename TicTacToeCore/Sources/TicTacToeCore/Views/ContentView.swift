import SwiftUI

public struct ContentView: View {
    public init() {}

    public var body: some View {
        GameBoardView()
            .environment()
    }
}

extension View {
    @ViewBuilder
    func environment(_ configuration: (GameBoard) -> Void = { _ in }) -> some View {
        let gameBoard = GameBoard.shared
        let _ = configuration(gameBoard)
        environment(gameBoard)
            .environment(PlayerMenuViewModel(gameBoard: gameBoard))
            .environment(GameBoardViewModel(gameBoard: gameBoard))
    }
}

#Preview {
    ContentView()
}
