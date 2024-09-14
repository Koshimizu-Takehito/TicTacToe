import SwiftUI

struct PlayerMenu: View {
    @Environment(GameBoard.self) private var gameBoard

    var body: some View {
        HStack(spacing: 0) {
            ForEach(Player.allCases, id: \.self) { player in
                Menu {
                    // モード選択
                    Group {
                        ForEach([PlayMode.player, PlayMode.random], id: \.self) { mode in
                            Button {
                                select(player: player, role: mode)
                            } label: {
                                Label(mode.title, systemImage: mode.systemImage)
                            }
                        }
                    }
                    // Computer 難易度選択
                    Menu {
                        ForEach(Difficulty.allCases, id: \.self) { difficulty in
                            let mode = PlayMode.computer(difficulty)
                            Button {
                                select(player: player, role: mode)
                            } label: {
                                Label(difficulty.title, systemImage: difficulty.systemImage)
                            }
                        }
                    } label: {
                        Label("Computer", systemImage: "x.squareroot")
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
    func select(player: Player, role: PlayMode) {
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
    PlayerMenu()
        .environment(GameBoard.shared)
}
