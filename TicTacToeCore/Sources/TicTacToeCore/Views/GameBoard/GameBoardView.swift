import SwiftUI

// MARK: - iOS
#if os(iOS) || os(macOS)
struct GameBoardView: View {
    @Environment(GameBoardViewModel.self) private var viewModel

    var body: some View {
        VStack {
            PlayerMenuView()
            GeometryReader(content: board(geometry:))
            ResetButton(action: viewModel.reset)
        }
        .padding()
        .background {
            viewModel.colorPalette.background
                .ignoresSafeArea()
        }
        .environment(\.colorPalette, viewModel.colorPalette)
    }
}

private struct ResetButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: "arrow.triangle.2.circlepath")
        }
        .buttonStyle(.titleStyle)
    }
}
#endif

// MARK: - watchOS
#if os(watchOS)
struct GameBoardView: View {
    @Environment(GameBoardViewModel.self) private var viewModel
    @State var isPresentingMenu: Bool = false

    var body: some View {
        NavigationStack {
            VStack {
                GeometryReader(content: board(geometry:))
            }
            .background {
                viewModel.colorPalette.background
                    .ignoresSafeArea()
            }
            .environment(\.colorPalette, viewModel.colorPalette)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        isPresentingMenu = true
                    } label: {
                        Image(systemName: "gearshape")
                    }
                }
            }
        }
        .sheet(isPresented: $isPresentingMenu) {
            PlayerMenuView()
        }
    }
}
#endif

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
}

#Preview {
    GameBoardView()
        .environment()
}
