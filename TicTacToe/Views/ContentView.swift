import SwiftUI

struct ContentView: View {
    @State var ratio: Double = 0
    @State var player: Player = .player1
    @State var checks: [IndexPath: Check] = [:]

    var body: some View {
        ZStack {
            VStack {
                GeometryReader { geometry in
                    let size = min(geometry.size.width, geometry.size.height)
                    let spacing = size/40
                    ZStack(alignment: .center) {
                        Group {
                            Lattice(lineWidth: spacing, color: .foreground, ratio: ratio)
                            Tiles(checks: $checks, spacing: spacing, onTap: update)
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
            checks = [:]
        }
    }

    func update(at index: IndexPath) -> Void {
        guard checks[index] == .none else { return }
        checks[index] = player.check
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
        guard checks.count < 9 else { return }

        while true {
            func random() -> Int { (0...2).randomElement()! }
            let random: IndexPath = [random(), random()]
            if checks[random] == nil {
                try await Task.sleep(nanoseconds: 450_000_000)
                update(at: random)
                return
            }
        }
    }
}

/// タイル領域
struct Tiles: View {
    @Binding var checks: [IndexPath: Check]
    var spacing: Double = 6
    let onTap: (IndexPath) -> Void

    var body: some View {
        Grid(horizontalSpacing: spacing, verticalSpacing: spacing) {
            ForEach(0..<3) { i in
                GridRow {
                    ForEach(0..<3) { j in
                        TileItemView(
                            lineWidth: spacing,
                            row: i,
                            column: j,
                            check: $checks[[i, j]],
                            onTap: onTap
                        )
                    }
                }
            }
        }
    }
}

struct TileItemView: View {
    let lineWidth: Double
    let row: Int
    let column: Int
    @Binding var check: Check?
    @State var ratio: Double = 0
    let onTap: (IndexPath) -> Void

    var body: some View {
        ZStack {
            Color.white
                .opacity(1/0xFFFF)
            Group {
                switch check {
                case .check1:
                    RingMark(ratio: ratio, lineWidth: lineWidth)
                case .check2:
                    CrossMark(ratio: ratio, lineWidth: lineWidth)
                case .none:
                    Color.clear
                }
            }
        }
        .onTapGesture {
            onTap([row, column])
        }
        .onChange(of: check) { oldValue, newValue in
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
