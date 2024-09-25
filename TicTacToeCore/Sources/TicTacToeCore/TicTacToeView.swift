import SwiftUI

public struct TicTacToeView: View {
    public init() {}

    public var body: some View {
        GameBoardView()
            .myEnvironment()
    }
}

#Preview {
    TicTacToeView()
}
