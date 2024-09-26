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
                    Section {
                        let mode = PlayMode.player
                        Button {
                            viewModel.select(player: player, role: mode)
                        } label: {
                            Label(mode.title, systemImage: mode.systemImage)
                        }
                    }
                    Section(PlayMode.computer().title) {
                        ForEach(Difficulty.allCases, id: \.self) { difficulty in
                            Button {
                                viewModel.select(player: player, role: .computer(difficulty))
                            } label: {
                                Label(difficulty.title, systemImage: difficulty.systemImage)
                            }
                        }
                    }
                } label: {
                    Color.clear
                        .frame(height: 0)
                        .overlay {
                            PlayerMenuLabel(
                                viewModel: .init(viewModel: viewModel, player: player)
                            )
                        }
                        .frame(maxWidth: .infinity)
                }
                .menuOrder(.fixed)
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
        Picker(PlayMode.computer().title, selection: $viewModel.difficulty) {
            ForEach(Difficulty.allCases, id: \.self) { item in
                Text(item.title).tag(item)
            }
        }
    }
}
#endif

@available(iOS 18.0, macOS 15.0, watchOS 11.0, *)
#Preview(traits: .myEnvironment) {
    PlayerMenuView()
}
