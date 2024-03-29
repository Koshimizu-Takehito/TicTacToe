import SwiftUI

struct GameBoardView: View {
    @State private var drawId = UUID()
    @State private var colorPalette: ColorPalette?
    @Environment(GameBoard.self) private var gameBoard

    var body: some View {
        ZStack {
            VStack {
                PlayerMenu()
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
            SymbolGridView(
                onTapGameResult: restartPlayerGame,
                onGameResultAnimationDidFinish: restartComputerGame
            )
            .allowsHitTesting(gameBoard.allowsHitTesting())
        }
        .frame(width: size, height: size)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .environment(\.latticeSpacing, size/40)
        .environment(\.symbolLineWidth, size/40)
        .id(drawId)
    }
}

private extension GameBoardView {
    func reset() {
        drawId = UUID()
        withAnimation(.custom(duration: 1)) {
            gameBoard.reset()
            colorPalette.reset()
        }
    }

    var isPlayerGame: Bool {
        gameBoard.role1 == .player || gameBoard.role2 == .player
    }

    func restartPlayerGame() {
        if isPlayerGame {
            reset()
        }
    }

    func restartComputerGame() {
        if !isPlayerGame {
            reset()
        }
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

private extension Optional<ColorPalette> {
    mutating func reset() {
        switch self {
        case .none:
            self = .default
        default:
            self = ColorPalette.allCases.randomElement()!
        }
    }
}

#Preview {
    GameBoardView()
        .environment(GameBoard())
        .environment(\.locale, .init(identifier: "en_US"))
}
