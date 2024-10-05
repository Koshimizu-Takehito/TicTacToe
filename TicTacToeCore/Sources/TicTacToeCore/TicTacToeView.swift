import SwiftUI

public struct TicTacToeView: View {
    @State var viewModel: GameBoardViewModel

    public init() {
        _viewModel = .init(initialValue: .init(gameBoard: .init()))
    }

    public var body: some View {
        GameBoardView()
            .modifier(GameBoardModifier(gameBoardViewModel: viewModel))
            .onOpenURL(perform: viewModel.recieve(url:))
    }
}

#Preview {
    TicTacToeView()
}
