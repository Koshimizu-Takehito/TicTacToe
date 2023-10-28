import SwiftUI

struct PlayerMenu: View {
    @Environment(GameBoard.self) private var gameBoard

    var body: some View {
        HStack(spacing: 0) {
            ForEach(Player.allCases, id: \.self) { player in
                Menu {
                    // 難易度選択
                    ForEach(PlayerMode.allCases, id: \.self) { role in
                        Button {
                            select(player: player, role: role)
                        } label: {
                            Label(role.title, systemImage: role.systemImage)
                        }
                    }
                    // シンボル選択
                    ControlGroup {
                        ForEach(Symbol.allCases, id: \.self) { symbol in
                            Button {
                                toggle(symbol: symbol, player: player)
                            } label: {
                                Text(String(describing: symbol))
                            }
                        }
                    }
                } label: {
                    Color.clear
                        .frame(height: 0)
                        .overlay { PlayerMenuLabel(player: player) }
                        .frame(maxWidth: .infinity)
                }
            }
        }
        .buttonStyle(ActionButtonStyle())
    }
}

private extension PlayerMenu {
    func select(player: Player, role: PlayerMode) {
        switch player {
        case .first:
            gameBoard.role1 = role
        case .second:
            gameBoard.role2 = role
        }
    }

    func toggle(symbol: Symbol, player: Player) {
        gameBoard.symbols[player] = symbol
        gameBoard.symbols[player.opposite] = symbol.opposite
    }
}

#Preview {
    struct _View: View {
        @State var role1: PlayerMode = .player
        @State var role2: PlayerMode = .computer
        @State var symbols = PlayerSymbolSetting()
        var body: some View {
            PlayerMenu()
        }
    }
    return _View()
        .environment(GameBoard())
}
