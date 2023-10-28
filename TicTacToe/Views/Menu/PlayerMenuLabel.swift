import SwiftUI

struct PlayerMenuLabel: View {
    let player: Player
    @Environment(GameBoard.self) private var gameBoard

    var body: some View {
        Label(
            title: { title },
            icon: { PlayerMenuIcon(symbol: gameBoard.symbols[player]) }
        )
        .fixedSize()
        .labelStyle(PlayerMenuLabelStyle())
    }

    @ViewBuilder
    var title: some View {
        switch role {
        case .computer(let difficulty):
            Text("\(role.title) \(difficulty.level)")
        default:
            Text("\(role.title)")
        }
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
    var gameBoard = GameBoard()
    gameBoard.symbols[.first] = .cross
    gameBoard.role1 = .computer(.easy)
    return PlayerMenuLabel(player: .first)
        .environment(gameBoard)
}
