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

private struct PlayerMenu: View {
    @Binding var role1: PlayerMode
    @Binding var role2: PlayerMode

    var body: some View {
        HStack {
            ForEach(Player.allCases, id: \.self, content: menu(player:))
        }
        .buttonStyle(ActionButtonStyle())
    }

    func menu(player: Player) -> some View {
        Menu {
            ForEach(PlayerMode.allCases, id: \.self) { role in
                Button(action: select(player: player, role: role), label: role.label)
            }
        } label: {
            Color.clear
                .frame(height: 0)
                .padding()
                .overlay { title(player: player) }
        }
    }

    @ViewBuilder
    func title(player: Player) -> some View {
        let role = player == .first ? role1 : role2
        let number = player == .first ? "1" : "2"
        Label("\(role.title)\(number)", systemImage: role.systemImage)
            .fixedSize()
    }

    func select(player: Player, role: PlayerMode) -> () -> Void {
        {
            switch player {
            case .first:
                role1 = role
            case .second:
                role2 = role
            }
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

#Preview {
    GameBoardView()
}
