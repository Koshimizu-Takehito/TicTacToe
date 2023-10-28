import SwiftUI

struct PlayerMenuTitle: View {
    let mode: PlayMode

    var body: some View {
        switch mode {
        case .computer(let difficulty):
            Text("\(mode.title) \(difficulty.level)")
        default:
            Text("\(mode.title)")
        }
    }
}

#Preview {
    PlayerMenuTitle(mode: .player)
}
