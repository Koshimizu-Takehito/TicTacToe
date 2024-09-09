import SwiftUI

/// 丸マーク
struct RingMark: View {
    var ratio: Double = 0
    @Environment(\.colorPalette.symbol1) private var color
    @Environment(\.symbolLineWidth) private var lineWidth

    var body: some View {
        RingShape(animatableData: ratio)
            .stroke(style: .init(lineWidth: lineWidth, lineCap: .round))
            .foregroundStyle(color)
    }

    private struct RingShape: Shape, Animatable {
        var animatableData: Double = 0

        func path(in rect: CGRect) -> Path {
            let ratio = animatableData
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

#Preview {
    RingMark(ratio: 1)
}
