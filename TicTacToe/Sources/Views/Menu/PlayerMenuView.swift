import SwiftUI

struct PlayerMenuView: View {
    @Environment(PlayerMenuViewModel.self)
    private var viewModel

    var body: some View {
        HStack(spacing: 0) {
            ForEach(Player.allCases, id: \.self) { player in
                Menu {
                    // モード選択
                    Group {
                        ForEach([PlayMode.player, .random], id: \.self) { mode in
                            Button {
                                viewModel.select(player: player, role: mode)
                            } label: {
                                Label(mode.title, systemImage: mode.systemImage)
                            }
                        }
                    }
                    // Computer 難易度選択
                    Menu {
                        ForEach(Difficulty.allCases, id: \.self) { difficulty in
                            Button {
                                viewModel.select(player: player, role: .computer(difficulty))
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
                                viewModel.toggle(symbol: symbol, player: player)
                            } label: {
                                Text(String(describing: symbol))
                            }
                        }
                    }
                } label: {
                    Color.clear
                        .frame(height: 0)
                        .overlay { PlayerMenuLabel(
                            viewModel: .init(viewModel: viewModel, player: player))
                        }
                        .frame(maxWidth: .infinity)
                }
            }
        }
        .buttonStyle(.actionStyle)
    }
}

#Preview {
    PlayerMenuView()
        .environment()
}
