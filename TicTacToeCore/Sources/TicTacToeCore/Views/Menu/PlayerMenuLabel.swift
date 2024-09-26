import SwiftUI

struct PlayerMenuLabel: View {
    var mode: PlayMode
    var symbol: Symbol

    var body: some View {
        Label(
            title: {
                PlayerMenuTitle(mode: mode)
            },
            icon: {
                PlayerMenuIcon(symbol: symbol)
            }
        )
        .fixedSize()
        .labelStyle(PlayerMenuLabelStyle())
    }
}

extension PlayerMenuLabel {
    init(viewModel: PlayerMenuIconViewModel) {
        self.init(mode: viewModel.mode, symbol: viewModel.symbol)
    }
}

private struct PlayerMenuLabelStyle: LabelStyle {
    @TextColor private var color

    func makeBody(configuration: Configuration) -> some View {
        HStack(spacing: 4) {
            configuration.icon
            configuration.title
        }
        .font(.title2.bold())
        .foregroundStyle(color)
    }
}

#Preview {
    Grid(alignment: .leading) {
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
