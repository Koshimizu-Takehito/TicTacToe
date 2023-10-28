import SwiftUI

struct ContentView: View {
    var body: some View {
        GameBoardView()
            .environment(GameBoardObject())
    }
}

#Preview {
    ContentView()
}
