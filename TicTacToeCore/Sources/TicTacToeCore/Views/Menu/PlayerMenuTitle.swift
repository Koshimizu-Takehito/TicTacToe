import SwiftUI

struct PlayerMenuTitle: View {
    let mode: PlayMode

    var body: some View {
        switch mode {
        case let .computer(difficulty):
            Text("\(difficulty.title)")
        default:
            Text("\(mode.title)")
        }
    }
}

#Preview {
    ForEach(PlayMode.allCases, id: \.self) { mode in
        PlayerMenuTitle(mode: mode)
    }
    .padding()
}
