import WidgetKit
import SwiftUI

struct RingMark: View {
    @Environment(\.colorPalette.symbol1) var color
    let lineWidth: Double

    var body: some View {
        RingShape()
            .stroke(lineWidth: lineWidth)
            .foregroundStyle(color)
    }
}

private struct RingShape: Shape {
    var ratio: Double = 1

    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.addArc(
            center: CGPoint(x: rect.midX, y: rect.midY),
            radius: 0.9 * min(rect.width / 2, rect.height / 2),
            startAngle: Angle(radians: -.pi / 2),
            endAngle: Angle(radians: -.pi / 2 + 2 * .pi * ratio),
            clockwise: true
        )
        return path
    }
}

#Preview(as: .accessoryRectangular) {
    WatchWidget()
} timeline: {
    TimelineEntry(date: .now)
}
