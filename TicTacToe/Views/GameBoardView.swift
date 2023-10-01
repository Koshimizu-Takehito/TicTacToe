import SwiftUI

struct GameBoardView: View {
    @State private var drawId = UUID()
    @State private var gameBoard = GameBoardObject()

    var body: some View {
        ZStack {
            VStack {
                GeometryReader(content: board(geometry:))
                ResetButton(action: reset)
            }
        }
        .padding()
        .modifier(Background())
        .onAppear(perform: reset)
    }

    @ViewBuilder
    func board(geometry: GeometryProxy) -> some View {
        let size = min(geometry.size.width, geometry.size.height)
        ZStack(alignment: .center) {
            LatticeView()
                .id(drawId)
            Tiles(marks: $gameBoard.marks, onTap: gameBoard.place(at:))
                .allowsHitTesting(gameBoard.player == .player1)
        }
        .frame(width: size, height: size)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .environment(\.latticeSpacing, size/40)
        .environment(\.markLineWidth, size/40)
    }

    func reset() {
        drawId = UUID()
        gameBoard.player = .player1
        withAnimation(.custom(duration: 1)) {
            gameBoard.marks = [:]
        }
    }
}

private struct ResetButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: "arrow.triangle.2.circlepath")
        }
        .buttonStyle(TitleButtonStyle(color: .foreground))
    }
}

#Preview {
    GameBoardView()
}
