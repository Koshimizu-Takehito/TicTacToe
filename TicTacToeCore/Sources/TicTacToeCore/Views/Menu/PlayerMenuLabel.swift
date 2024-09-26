import SwiftUI

// MARK: - PlayerMenuLabel

struct PlayerMenuLabel: View {
    @TextColor private var color
    var mode: PlayMode
    var symbol: Symbol

    var body: some View {
        VStack(spacing: 0) {
            Text("\(mode.title)")
                .font(.subheadline)
                .foregroundStyle(mode == .player ? .clear : color)
            Label(
                title: {
                    PlayerMenuTitle(mode: mode)
                },
                icon: {
                    PlayerMenuIcon(symbol: symbol)
                }
            )
            .fixedSize()
            .font(.title2.bold())
            .foregroundStyle(color)
            .labelStyle(PlayerMenuLabelStyle())
        }
    }
}

// MARK: -

extension PlayerMenuLabel {
    init(viewModel: PlayerMenuIconViewModel) {
        self.init(mode: viewModel.mode, symbol: viewModel.symbol)
    }
}

// MARK: - PlayerMenuLabelStyle

private struct PlayerMenuLabelStyle: LabelStyle {
    @TextColor private var color

    func makeBody(configuration: Configuration) -> some View {
        HStack(spacing: 4) {
            configuration.icon
            configuration.title
        }
    }
}

// MARK: - Preview

#Preview {
    Grid {
        ForEach(PlayMode.allCases, id: \.self) { mode in
            GridRow {
                ForEach(Symbol.allCases, id: \.self) { symbol in
                    PlayerMenuLabel(mode: mode, symbol: symbol)
                        .padding(.horizontal)
                }
            }
        }
    }
}
