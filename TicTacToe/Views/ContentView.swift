import SwiftUI

struct ContentView: View {
    var body: some View {
        GameBoardView()
            .environment()
    }
}

extension View {
    @ViewBuilder
    func environment() -> some View {
        let gameBoard = GameBoard.shared
        self.environment(gameBoard)
            .environment(GameBoardViewModel(gameBoard: gameBoard))
    }
}

#Preview {
    ContentView()
}
