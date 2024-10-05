import SwiftUI

public struct CrossMark: View {
    @Environment(\.colorPalette.symbol2) var color
    let lineWidth: Double

    public init(lineWidth: Double) {
        self.lineWidth = lineWidth
    }

    public var body: some View {
        CrossShape()
            .stroke(lineWidth: lineWidth)
            .foregroundStyle(color)
    }
}

private struct CrossShape: Shape, Animatable {
    var ratio: Double = 1

    func path(in rect: CGRect) -> Path {
        let r0 = 1.2 * min(rect.width / 2, rect.height / 2)
        let r1 = 4.0 * r0 * min(ratio, 0.5)
        let r2 = 4.0 * r0 * max(ratio - 0.5, 0.0)

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
