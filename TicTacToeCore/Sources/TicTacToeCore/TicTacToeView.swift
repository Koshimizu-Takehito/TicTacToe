import SwiftUI

public struct TicTacToeView: View {
    public init() {}

    public var body: some View {
        GameBoardView()
            .modifier(GameBoardModifier(gameBoard: GameBoard()))
    }
}

#Preview {
    TicTacToeView()
}
