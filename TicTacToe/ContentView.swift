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
        withAnimation(.custom()) {
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

enum Check: Hashable {
    case check1
    case check2
}

struct TileItem: View {
    @Binding var check: Check?
    @State var ratio: Double = 0

    var body: some View {
        ZStack {
            Color.white.opacity(1/256)
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

/// 丸マーク
struct RingMark: View {
    var ratio: Double = 0
    var lineWidth: Double = 6.0
    var color: Color = .white

    var body: some View {
        RingShape(animatableData: ratio)
            .stroke(lineWidth: lineWidth)
            .foregroundStyle(color)
    }

    private struct RingShape: Shape, Animatable {
        var animatableData: Double = 0
        var ratio: Double { animatableData }

        func path(in rect: CGRect) -> Path {
            var path = Path()
            path.addArc(
                center: CGPoint(x: rect.midX, y: rect.midY),
                radius: 0.6 * min(rect.width/2, rect.height/2),
                startAngle: Angle(radians: -.pi/2),
                endAngle: Angle(radians: -.pi/2 + 2 * .pi * ratio),
                clockwise: false
            )
            return path
        }
    }
}

/// バツマーク
struct CrossMark: View {
    var ratio: Double = 0
    var lineWidth: Double = 6.0
    var color: Color = .white

    var body: some View {
        CrossShape(animatableData: ratio)
            .stroke(lineWidth: lineWidth)
            .foregroundStyle(color)
    }

    private struct CrossShape: Shape, Animatable {
        var animatableData: Double = 0
        var ratio: Double { animatableData }

        func path(in rect: CGRect) -> Path {
            let r0 = 0.8 * min(rect.width/2, rect.height/2)
            let r1 = 4 * r0 * min(ratio, 0.5)
            let r2 = 4 * r0 * max(ratio - 0.5, 0.0)

            let p0 = CGPoint(x: rect.midX, y: rect.midY)
            let p1 = p0 + CGPoint(radius: r0, theta: 7/4 * .pi)
            let p2 = p1 + CGPoint(radius: r1, theta: 7/4 * .pi - .pi)
            let p3 = p0 + CGPoint(radius: r0, theta: 5/4 * .pi)
            let p4 = p3 + CGPoint(radius: r2, theta: 5/4 * .pi - .pi)

            var path = Path()
            path.move(to: p1)
            path.addLine(to: p2)
            path.move(to: p3)
            path.addLine(to: p4)
            return path
        }
    }
}

/// 格子
struct Lattice: View, Animatable {
    var animatableData: Double {
        get { ratio }
        set { ratio = newValue }
    }

    var lineWidth: Double
    var color: Color
    var ratio: Double

    var body: some View {
        Canvas { context, size in
            let size = min(size.width, size.height)
            let length: Double = size
            [
                // タテ（左）
                CGRect(
                    x: 1.0 * size/3.0 - lineWidth/2.0,
                    y: (1.0 - ratio) * length/2,
                    width: lineWidth,
                    height: length * ratio
                ),
                // タテ（右）
                CGRect(
                    x: 2.0 * size/3.0 - lineWidth/2.0,
                    y: (1.0 - ratio) * length/2,
                    width: lineWidth,
                    height: length * ratio
                ),
                // ヨコ（上）
                CGRect(
                    x: (1.0 - ratio) * length/2,
                    y: 1.0 * size/3.0 - lineWidth/2.0,
                    width: length * ratio,
                    height: lineWidth
                ),
                // ヨコ（下）
                CGRect(
                    x: (1.0 - ratio) * length/2,
                    y: 2.0 * size/3.0 - lineWidth/2.0,
                    width: length * ratio,
                    height: lineWidth
                )
            ]
                .map { Path(roundedRect: $0, cornerSize: .zero) }
                .forEach { context.fill($0, with: .color(color)) }
        }
    }
}

/// 背景
struct Background: ViewModifier {
    let color: Color

    func body(content: Content) -> some View {
        content
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(in: Rectangle())
            .backgroundStyle(color)
            .ignoresSafeArea()
    }
}

struct TitleButtonStyle: ButtonStyle {
    var color: Color = .blue

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.title.bold())
            .foregroundStyle(color)
            .frame(minHeight: 44)
            .padding(.horizontal)
            .opacity(configuration.isPressed ? 0.2 : 1)
    }
}

extension Animation {
    static func custom() -> Animation {
        .spring(duration: 0.7)
    }
}

extension CGPoint {
    init(radius: Double, theta: Double) {
        self.init(x: radius * cos(theta), y: radius * sin(theta))
    }

    static func +(_ lhs: Self, _ rhs: Self) -> Self {
        return self.init(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
    }

    static func -(_ lhs: Self, _ rhs: Self) -> Self {
        return self.init(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
    }

    static func *(_ lhs: Double, _ rhs: Self) -> Self {
        return self.init(x: lhs * rhs.x, y: lhs * rhs.y)
    }
}

#Preview {
    ContentView()
}
