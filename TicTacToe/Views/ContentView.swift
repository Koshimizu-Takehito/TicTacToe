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
                    let spacing = size/40
                    ZStack(alignment: .center) {
                        Group {
                            Lattice(lineWidth: spacing, color: .foreground, ratio: ratio)
                            Tiles(marks: $marks, spacing: spacing, onTap: update)
                                .allowsHitTesting(player == .player1)
                        }
                        .frame(width: size, height: size)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                Button(action: reset, label: {
                    Image(systemName: "arrow.triangle.2.circlepath")
                })
                .buttonStyle(TitleButtonStyle(color: .foreground))
            }
        }
        .padding()
        .modifier(Background(color: .background))
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

/// タイル領域
struct Tiles: View {
    @Binding var marks: [IndexPath: MarkType]
    var spacing: Double = 6
    let onTap: (IndexPath) -> Void

    var body: some View {
        Grid(horizontalSpacing: spacing, verticalSpacing: spacing) {
            ForEach(0..<3) { i in
                GridRow {
                    ForEach(0..<3) { j in
                        let indexPath: IndexPath = [i, j]
                        MarkView(
                            lineWidth: spacing,
                            mark: $marks[indexPath]
                        )
                        .onTapGesture { onTap(indexPath) }
                    }
                }
            }
        }
    }
}

struct MarkView: View {
    let lineWidth: Double
    @Binding var mark: MarkType?
    @State var ratio: Double = 0

    var body: some View {
        ZStack {
            Color.white
                .opacity(1/0xFFFF)
            Group {
                switch mark {
                case .circle:
                    RingMark(ratio: ratio, lineWidth: lineWidth)
                case .cross:
                    CrossMark(ratio: ratio, lineWidth: lineWidth)
                case .none:
                    Color.clear
                }
            }
        }
        .onChange(of: mark) { oldValue, newValue in
            ratio = 0
            withAnimation(.custom()) {
                ratio = 1
            }
        }
    }
}

#Preview {
    ContentView()
}
