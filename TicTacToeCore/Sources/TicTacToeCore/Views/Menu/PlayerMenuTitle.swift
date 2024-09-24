import SwiftUI

struct PlayerMenuTitle: View {
    let mode: PlayMode

    var body: some View {
        switch mode {
        case let .computer(difficulty):
            Text("\(mode.title) \(difficulty.level)", bundle: .module)
        default:
            Text("\(mode.title)", bundle: .module)
        }
    }
}

#Preview {
    PlayerMenuTitle(mode: .computer(.hard))
}
