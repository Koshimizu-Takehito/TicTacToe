import SwiftUI
import TicTacToeWidgetCore
import WidgetKit

struct ContentView: View {
    @Environment(\.widgetRenderingMode) var renderingMode
    @Environment(\.colorPalette) var colorPalette

    var body: some View {
        GeometryReader { geometry in
            let padding = 0.08 * min(geometry.size.width, geometry.size.height)
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
            .padding(padding)
        }
        .background(background, in: .circle)
        .widgetAccentable()
    }
}

private extension ContentView {
    var background: Color {
        switch renderingMode {
        case .fullColor:
            colorPalette.background
        default:
            colorPalette.background.opacity(0.2)
        }
    }
}

#Preview(as: .accessoryCircular) {
    WatchWidget()
} timeline: {
    TimelineEntry(date: .now)
}
