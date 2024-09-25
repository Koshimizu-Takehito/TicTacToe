import SwiftUI

struct PlayerMenuLabel: View {
    var viewModel: PlayerMenuIconViewModel

    var body: some View {
        Label(
            title: {
                PlayerMenuTitle(mode: viewModel.mode)
            },
            icon: {
                PlayerMenuIcon(symbol: viewModel.symbol)
            }
        )
        .fixedSize()
        .labelStyle(PlayerMenuLabelStyle())
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
