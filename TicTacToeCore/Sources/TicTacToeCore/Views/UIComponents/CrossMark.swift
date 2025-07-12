import SwiftUI

/// View that draws the "X" mark used on the board.
struct CrossMark: View {
    private var ratio: Double = 0
    @Environment(\.colorPalette.symbol2) private var color
    @Environment(\.symbolLineWidth) private var lineWidth
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    init(ratio: Double = 0) {
        self.ratio = ratio
    }

    var body: some View {
        CrossShape(animatableData: reduceMotion ? 1 : ratio)
            .stroke(lineWidth: lineWidth)
            .foregroundStyle(color)
            .opacity(reduceMotion ? ratio : 1)
    }

    private struct CrossShape: Shape, Animatable {
        var animatableData: Double = 0

        func path(in rect: CGRect) -> Path {
            let ratio = animatableData
            let r0 = 0.8 * min(rect.width / 2, rect.height / 2)
            let r1 = 4 * r0 * min(ratio, 0.5)
            let r2 = 4 * r0 * max(ratio - 0.5, 0.0)

            let p0 = CGPoint(x: rect.midX, y: rect.midY)
            let p1 = p0 + CGPoint(radius: r0, radian: 7 / 4 * .pi)
            let p2 = p1 + CGPoint(radius: r1, radian: 7 / 4 * .pi - .pi)
            let p3 = p0 + CGPoint(radius: r0, radian: 5 / 4 * .pi)
            let p4 = p3 + CGPoint(radius: r2, radian: 5 / 4 * .pi - .pi)

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
    CrossMark(ratio: 1)
}
