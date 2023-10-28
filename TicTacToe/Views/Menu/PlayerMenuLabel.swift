import SwiftUI

struct PlayerMenuLabel: View {
    let player: Player
    @Environment(GameBoardObject.self) private var gameBoard

    var body: some View {
        Label(
            title: { Text("\(role.title)") },
            icon: { PlayerMenuIcon(symbol: symbol) }
        )
        .fixedSize()
        .labelStyle(PlayerMenuLabelStyle())
    }
}

private extension PlayerMenuLabel {
    var role: PlayerMode {
        player == .first ? gameBoard.role1 : gameBoard.role2
    }

    var symbol: Symbol {
        gameBoard.symbols[player]
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
        .environment(GameBoardObject())
}
