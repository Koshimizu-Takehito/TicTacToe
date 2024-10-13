import SwiftUI

struct GameBoardInnerView: View {
    let viewModel: GameBoardViewModel

    var body: some View {
        GeometryReader { geometry in
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
        .background {
            viewModel.colorPalette.background
                .ignoresSafeArea()
        }
    }
}

@available(iOS 18.0, macOS 15.0, watchOS 11.0, *)
#Preview(traits: .myEnvironment) {
    @Previewable @Environment(GameBoardViewModel.self) var viewModel

    GameBoardInnerView(viewModel: viewModel)
}
