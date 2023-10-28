import SwiftUI

struct ContentView: View {
    var body: some View {
        GameBoardView()
            .environment(GameBoard())
    }
}

#Preview {
    ContentView()
}
