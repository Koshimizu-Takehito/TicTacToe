import WidgetKit
import SwiftUI

struct RingMark: View {
    @Environment(\.colorPalette.symbol1) var color
    let lineWidth: Double

    var body: some View {
        Circle()
            .stroke(lineWidth: lineWidth)
            .foregroundStyle(color)
    }
}

#Preview(as: .accessoryRectangular) {
    WatchWidget()
} timeline: {
    TimelineEntry(date: .now)
}
