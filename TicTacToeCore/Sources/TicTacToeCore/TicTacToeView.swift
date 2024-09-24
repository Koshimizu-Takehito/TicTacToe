import SwiftUI

public struct TicTacToeView: View {
    public init() {}

    public var body: some View {
        GameBoardView()
            .environment(gameBoard: GameBoard())
    }
}

#Preview {
    TicTacToeView()
}
