import SwiftUI

struct PlayerMenuLabel: View {
    let player: Player
    @Environment(GameBoard.self) private var gameBoard

    var body: some View {
        Label(
            title: { Text("\(role.title)") },
            icon: { PlayerMenuIcon(symbol: gameBoard.symbols[player]) }
        )
        .fixedSize()
        .labelStyle(PlayerMenuLabelStyle())
    }
}

private extension PlayerMenuLabel {
    var role: PlayMode {
        player == .first ? gameBoard.role1 : gameBoard.role2
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
    PlayerMenuLabel(player: .first)
        .environment(GameBoard())
}
