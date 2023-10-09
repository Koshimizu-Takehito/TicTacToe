import SwiftUI

/// バツマーク
struct CrossMark: View {
    private var ratio: Double = 0
    @Environment(\.markColor2) private var color
    @Environment(\.symbolLineWidth) private var lineWidth

    init(ratio: Double = 0) {
        self.ratio = ratio
    }

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

#Preview {
    AnimationHelper(.spring(duration: 1), start: 0, end: 1) { parameter in
        CrossMark(ratio: parameter)
    }
}
