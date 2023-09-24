import SwiftUI

struct ContentView: View {
    @State var ratio: Double = 0
    @State var player: Player = .player1
    @State var checks: [[Check?]] = .default

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
            checks = .default
        }
    }

    func update(row: Int, column: Int) -> Void {
        guard checks[row][column] == .none else { return }
        checks[row][column] = player.check
        player.toggle()
    }

    func changePlayer(old: Player, new: Player) {
        switch new {
        case .player1:
            break
        case .player2:
            let canPlay = checks.lazy.flatMap { $0 }.contains { $0 == nil }
            guard canPlay else { return }
            while true {
                let row = (0...2).randomElement()!
                let column = (0...2).randomElement()!
                if checks[row][column] == nil {
                    Task { @MainActor in
                        try await Task.sleep(nanoseconds: 450_000_000)
                        update(row: row, column: column)
                    }
                    break
                } else {
                    continue
                }
            }
        }
    }
}

extension [[Check?]] {
    static var `default`: Self {
        .init(
            repeating: .init(repeating: .none, count: 3),
            count: 3
        )
    }
}

/// タイル領域
struct Tiles: View {
    @Binding var checks: [[Check?]]
    var spacing: Double = 6
    let onTap: ((row: Int, column: Int)) -> Void

    var body: some View {
        Grid(horizontalSpacing: spacing, verticalSpacing: spacing) {
            ForEach(0..<3) { i in
                GridRow {
                    ForEach(0..<3) { j in
                        TileItemView(
                            lineWidth: spacing,
                            row: i,
                            column: j,
                            check: $checks[i][j],
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
    let onTap: ((row: Int, column: Int)) -> Void

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
            onTap((row: row, column: column))
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
