import SwiftUI

struct ContentView: View {
    @State var ratio: Double = 0
    @State var player: Player = .player1
    @State var marks: [IndexPath: MarkType] = [:]

    var body: some View {
        ZStack {
            VStack {
                GeometryReader { geometry in
                    let size = min(geometry.size.width, geometry.size.height)
                    ZStack(alignment: .center) {
                        Group {
                            Lattice(ratio: ratio)
                            Tiles(marks: $marks, onTap: update)
                                .allowsHitTesting(player == .player1)
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
        .onChange(of: player, changePlayer)
    }

    func reset() {
        ratio = 0
        player = .player1
        withAnimation(.custom(duration: 1)) {
            ratio = 1
            marks = [:]
        }
    }

    func update(at index: IndexPath) -> Void {
        guard marks[index] == .none else { return }
        marks[index] = player.check
        player.toggle()
    }

    func changePlayer(old: Player, new: Player) {
        switch new {
        case .player1:
            break
        case .player2:
            Task { try await placeAtRandom() }
        }
    }

    /// ランダムな位置に配置する
    func placeAtRandom() async throws {
        guard marks.count < 9 else { return }

        while true {
            func random() -> Int { (0...2).randomElement()! }
            let random: IndexPath = [random(), random()]
            if marks[random] == nil {
                try await Task.sleep(nanoseconds: 550_000_000)
                update(at: random)
                return
            }
        }
    }
}

#Preview {
    ContentView()
}
