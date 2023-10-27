import SwiftUI

struct GameBoardView: View {
    @State private var drawId = UUID()
    @State private var colorPalette: ColorPalette?
    @State private var gameBoard = GameBoardObject()

    var body: some View {
        ZStack {
            VStack {
                PlayerMenu(role1: $gameBoard.role1, role2: $gameBoard.role2)
                GeometryReader(content: board(geometry:))
                ResetButton(action: reset)
            }
        }
        .padding()
        .modifier(Background())
        .onAppear(perform: reset)
        .environment(\.colorPalette, colorPalette ?? .default)
    }

    @ViewBuilder
    func board(geometry: GeometryProxy) -> some View {
        let size = min(geometry.size.width, geometry.size.height)
        ZStack(alignment: .center) {
            LatticeView()
                .id(drawId)
            SymbolGridView(
                gameState: gameBoard.gameState,
                occupied: $gameBoard.occupied,
                onTap: gameBoard.place(at:),
                onTapGameResult: restartPlayerGame,
                onGameResultAnimationDidFinish: restartComputerGame
            )
            .allowsHitTesting(gameBoard.allowsHitTesting())
            .id(drawId)
        }
        .frame(width: size, height: size)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .environment(\.latticeSpacing, size/40)
        .environment(\.symbolLineWidth, size/40)
    }
}

private extension GameBoardView {
    func reset() {
        drawId = UUID()
        withAnimation(.custom(duration: 1)) {
            gameBoard.reset()
        }

        switch colorPalette {
        case .none:
            colorPalette = .default
        case .some:
            withAnimation(.custom(duration: 0.5)) {
                colorPalette = ColorPalette.allCases.randomElement()!
            }
        }
    }

    func restartPlayerGame() {
        guard gameBoard.role1 == .player || gameBoard.role2 == .player else { return }
        reset()
    }

    func restartComputerGame() {
        guard gameBoard.role1 != .player && gameBoard.role2 != .player else { return }
        reset()
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
}
