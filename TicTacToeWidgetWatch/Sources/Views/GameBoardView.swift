import SwiftUI
import WidgetKit

struct GameBoardView: View {
    @Environment(\.widgetRenderingMode) var renderingMode
    @Environment(\.colorPalette) var colorPalette

    var body: some View {
        GeometryReader { geometry in
            let edge = min(geometry.size.width, geometry.size.height)
            let spacing = 0.08 * edge
            let lineWidth = 0.06 * edge
            Grid(horizontalSpacing: spacing, verticalSpacing: spacing) {
                GridRow {
                    RingMark(lineWidth: lineWidth)
                    CrossMark(lineWidth: lineWidth)
                }
                GridRow {
                    CrossMark(lineWidth: lineWidth)
                    RingMark(lineWidth: lineWidth)
                }
            }
            .frame(width: edge - 3 * spacing, height: edge - 3 * spacing)
            .frame(maxWidth: .infinity, maxHeight: .infinity)

        }
        .padding(6)
        .background(background, in: .circle)
    }
}

private extension GameBoardView {
    var background: Color {
        switch renderingMode {
        case .fullColor:
            colorPalette.background
        default:
            colorPalette.background.opacity(0.5)
        }
    }
}

#Preview(as: .accessoryCircular) {
    WatchWidget()
} timeline: {
    TimelineEntry(date: .now)
}
