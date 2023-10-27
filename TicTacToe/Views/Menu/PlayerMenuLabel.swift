import SwiftUI

struct PlayerMenuLabel: View {
    let role: PlayerMode
    let symbol: Symbol

    var body: some View {
        Label(
            title: { Text("\(role.title)") },
            icon: { PlayerMenuIcon(symbol: symbol) }
        )
        .fixedSize()
        .labelStyle(PlayerMenuLabelStyle())
    }
}

private struct PlayerMenuLabelStyle: LabelStyle {
    @Environment(\.colorPalette.foreground) private var color

    func makeBody(configuration: Configuration) -> some View {
        HStack {
            configuration.icon
            configuration.title
        }
        .font(.title2.bold())
        .foregroundStyle(color)
    }
}

#Preview {
    PlayerMenuLabel(role: .player, symbol: .circle)
}
