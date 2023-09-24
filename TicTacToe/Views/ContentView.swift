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
                            Tiles(checks: $checks, spacing: spacing, onTap: onTap)
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
    }

    func reset() {
        ratio = 0
        withAnimation(.custom(duration: 1)) {
            ratio = 1
            checks = .default
        }
    }

    func onTap(row: Int, column: Int) -> Void {
        guard checks[row][column] == .none else { return }
        checks[row][column] = player.check
        player.toggle()
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
