import SwiftUI

struct GameBoardView: View {
    @State private var ratio: Double = 0
    @State private var gameBoard = GameBoardObject()

    var body: some View {
        ZStack {
            VStack {
                GeometryReader { geometry in
                    let size = min(geometry.size.width, geometry.size.height)
                    ZStack(alignment: .center) {
                        Group {
                            Lattice(ratio: ratio)
                            Tiles(marks: $gameBoard.gameBoard.marks, onTap: gameBoard.place)
                                .allowsHitTesting(gameBoard.player == .player1)
                        }
                        .frame(width: size, height: size)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .environment(\.latticeSpacing, size/40)
                    .environment(\.markLineWidth, size/40)
                }
                Button(action: reset, label: {
                    Image(systemName: "arrow.triangle.2.circlepath")
                })
                .buttonStyle(TitleButtonStyle(color: .foreground))
            }
        }
        .padding()
        .modifier(Background())
        .onAppear(perform: reset)
    }

    func reset() {
        ratio = 0
        gameBoard.player = .player1
        withAnimation(.custom(duration: 1)) {
            ratio = 1
            gameBoard.gameBoard.marks = [:]
        }
    }
}

#Preview {
    GameBoardView()
}
