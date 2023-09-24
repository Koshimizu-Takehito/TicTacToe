import SwiftUI

struct ContentView: View {
    @State var ratio: Double = 0
    var spacing: Double = 6

    var body: some View {
        ZStack {
            VStack {
                GeometryReader { geometry in
                    let size = min(geometry.size.width, geometry.size.height)
                    ZStack(alignment: .center) {
                        Group {
                            Lattice(lineWidth: spacing, color: .blue, ratio: ratio)
                            Tiles(spacing: spacing)
                        }
                        .frame(width: size, height: size)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }

                Button("リセット", action: reset)
                    .buttonStyle(TitleButtonStyle())
            }
        }
        .padding()
        .modifier(Background(color: .orange))
        .onAppear(perform: reset)
    }

    func reset() {
        ratio = 0
        withAnimation(.custom(duration: 1)) {
            ratio = 1
        }
    }
}

/// タイル領域
struct Tiles: View {
    var spacing: Double = 6
    @State var checks: [[Check?]] = [
        [.check1, .check2, .check1],
        [.check2, .check1, .check2],
        [.check1, .check2, .check1],
    ]

    var body: some View {
        Grid(horizontalSpacing: spacing, verticalSpacing: spacing) {
            ForEach(0..<3) { i in
                GridRow {
                    ForEach(0..<3) { j in
                        TileItem(check: $checks[i][j])
                    }
                }
            }
        }
//        .allowsHitTesting(false)
    }
}

struct TileItem: View {
    @Binding var check: Check?
    @State var ratio: Double = 0

    var body: some View {
        ZStack {
            Color.white.opacity(1/0xFFFF)
            Group {
                switch check {
                case .check1:
                    RingMark(ratio: ratio)
                case .check2:
                    CrossMark(ratio: ratio)
                case .none:
                    Color.clear
                }
            }
        }
        .onTapGesture {
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
