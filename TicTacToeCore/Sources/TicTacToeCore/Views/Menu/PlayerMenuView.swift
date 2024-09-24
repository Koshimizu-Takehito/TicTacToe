import SwiftUI

// MARK: - iOS
#if os(iOS) || os(macOS)
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
                        Label(String(localized: "Computer", bundle: .module), systemImage: "x.squareroot")
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
#endif

// MARK: - watchOS
#if os(watchOS)
struct PlayerMenuView: View {
    @Environment(PlayerMenuViewModel.self) private var viewModel

    var body: some View {
        @Bindable var viewModel = viewModel
        Picker("Computer", selection: $viewModel.difficulty) {
            ForEach.init(Difficulty.allCases, id: \.self) { item in
                Text(item.title).tag(item)
            }
        }
    }
}
#endif

#Preview {
    PlayerMenuView()
        .environment()
}
