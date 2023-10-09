import SwiftUI

struct GameBoardView: View {
    @State private var drawId = UUID()
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
    }

    @ViewBuilder
    func board(geometry: GeometryProxy) -> some View {
        let size = min(geometry.size.width, geometry.size.height)
        ZStack(alignment: .center) {
            LatticeView()
                .id(drawId)
            SymbolGridView(gameState: gameBoard.gameState, symbols: $gameBoard.symbols, onTap: gameBoard.place(at:))
                .allowsHitTesting(gameBoard.canPlay())
        }
        .frame(width: size, height: size)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .environment(\.latticeSpacing, size/40)
        .environment(\.markLineWidth, size/40)
    }

    func reset() {
        drawId = UUID()
        withAnimation(.custom(duration: 1)) {
            gameBoard.reset()
        }
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
        let role = player == .player1 ? role1 : role2
        let number = player == .player1 ? "1" : "2"
        Label("\(role.title)\(number)", systemImage: role.systemImage)
            .fixedSize()
    }

    func select(player: Player, role: PlayerMode) -> () -> Void {
        {
            switch player {
            case .player1:
                role1 = role
            case .player2:
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
