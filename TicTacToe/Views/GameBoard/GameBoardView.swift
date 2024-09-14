import SwiftUI

struct GameBoardView: View {
    @Environment(GameBoardViewModel.self)
    private var viewModel

    var body: some View {
        VStack {
            PlayerMenuView()
            GeometryReader(content: board(geometry:))
            ResetButton(action: viewModel.reset)
        }
        .padding()
        .background {
            background
                .ignoresSafeArea()
        }
        .environment(\.colorPalette, viewModel.colorPalette)
    }
}

private extension GameBoardView {
    @ViewBuilder
    func board(geometry: GeometryProxy) -> some View {
        let size = min(geometry.size.width, geometry.size.height)
        ZStack(alignment: .center) {
            LatticeView()
            SymbolGridView(
                onTapGameResult: viewModel.restartPlayerGame,
                onGameResultAnimationDidFinish: viewModel.restartComputerGame
            )
            .allowsHitTesting(viewModel.allowsHitTesting())
        }
        .frame(width: size, height: size)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .environment(\.latticeSpacing, size / 40)
        .environment(\.symbolLineWidth, size / 40)
        .id(viewModel.drawId)
    }

    @ViewBuilder
    var background: Color {
        viewModel.colorPalette.background
    }
}

private struct ResetButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: "arrow.triangle.2.circlepath")
        }
        .buttonStyle(TitleButtonStyle())
    }
}

#Preview {
    GameBoardView()
        .environment()
}
