import SwiftUI

struct ContentView: View {
    @State var ratio: Double = 0
    var spacing: Double = 6

    var body: some View {
        ZStack {
            Center { _ in
                Lattice(lineWidth: spacing, color: .blue, ratio: ratio)
            }
            Center { _ in
                Tiles(spacing: spacing)
            }
        }
        .padding()
        .modifier(Background(color: .orange))
        .onAppear {
            withAnimation(.custom()) {
                ratio = 1
            }
        }
    }
}

struct Center<V: View>: View {
    var content: (CGFloat) -> V

    init(@ViewBuilder content: @escaping (_ size: CGFloat) -> V) {
        self.content = content
    }

    var body: some View {
        GeometryReader { geometry in
            let size = min(geometry.size.width, geometry.size.height)
            VStack(spacing: 0) {
                Spacer()
                    .frame(minHeight: 0)
                HStack {
                    Spacer()
                        .frame(minWidth: 0)
                    content(size)
                        .frame(width: size, height: size)
                    Spacer()
                        .frame(minWidth: 0)
                }
                Spacer()
                    .frame(minHeight: 0)
            }
        }
    }
}

/// タイル
struct Tiles: View {
    var spacing: Double = 6

    var body: some View {
        Grid(horizontalSpacing: spacing, verticalSpacing: spacing) {
            GridRow {
                Color.clear.overlay {
                    CrossMark()
                }
                Color.clear.overlay {
                    RingMark()
                }
                Color.clear.overlay {
                    RingMark()
                }
            }
            GridRow {
                Color.clear.overlay {
                    RingMark()
                }
                Color.clear.overlay {
                    RingMark()
                }
                Color.clear.overlay {
                    RingMark()
                }
            }
            GridRow {
                Color.clear.overlay {
                    RingMark()
                }
                Color.clear.overlay {
                    RingMark()
                }
                Color.clear.overlay {
                    RingMark()
                }
            }
        }
    }
}

/// 丸マーク
struct RingMark: View {
    @State var ratio: Double = 0
    var lineWidth: Double = 6.0
    var color: Color = .white

    var body: some View {
        RingShape(animatableData: ratio)
            .stroke(lineWidth: lineWidth)
            .foregroundStyle(color)
            .onAppear {
                withAnimation(.custom()) {
                    ratio = 1
                }
            }
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
    @State var ratio: Double = 0
    var lineWidth: Double = 6.0
    var color: Color = .white

    var body: some View {
        CrossShape(animatableData: ratio)
            .stroke(lineWidth: lineWidth)
            .foregroundStyle(color)
            .onAppear {
                withAnimation(.custom()) {
                    ratio = 1
                }
            }
    }

    private struct CrossShape: Shape, Animatable {
        var animatableData: Double = 0
        var ratio: Double { animatableData }

        func path(in rect: CGRect) -> Path {
            let center = CGPoint(x: rect.midX, y: rect.midY)
            let radius = ratio * 0.8 * min(rect.width/2, rect.height/2)
            let pp = [
                center + CGPoint(radius: radius, theta: 1/4 * .pi),
                center + CGPoint(radius: radius, theta: 3/4 * .pi),
                center + CGPoint(radius: radius, theta: 5/4 * .pi),
                center + CGPoint(radius: radius, theta: 7/4 * .pi)
            ]
            var path = Path()
            path.move(to: center); path.addLine(to: pp[0])
            path.move(to: center); path.addLine(to: pp[1])
            path.move(to: center); path.addLine(to: pp[2])
            path.move(to: center); path.addLine(to: pp[3])
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

extension Animation {
    static func custom() -> Animation {
        .spring(duration: 0.5)
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
