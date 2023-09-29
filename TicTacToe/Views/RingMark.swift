import SwiftUI

/// 丸マーク
struct RingMark: View {
    var ratio: Double = 0
    @Environment(\.markColor1) private var color
    @Environment(\.markLineWidth) private var lineWidth

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

#Preview {
    AnimationHelper(start: 0, end: 1) { parameter in
        RingMark(ratio: parameter)
    }
}
