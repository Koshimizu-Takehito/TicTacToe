import SwiftUI
import WidgetKit
import TicTacToeWidgetCore

struct ContentView: View {
    @Environment(\.widgetFamily) var widgetFamily
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
                .widgetAccentable(false)
            }
            .frame(width: edge - 3 * spacing, height: edge - 3 * spacing)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(background, in: .rect)
            .widgetAccentable()
        }
    }
}

private extension ContentView {
#if os(iOS)
    var background: Color {
        // renderingMode
        switch widgetFamily {
        case .systemSmall, .systemMedium, .systemLarge, .systemExtraLarge:
            switch renderingMode {
            case .fullColor:
                colorPalette.background
            default:
                Color.black.opacity(0.2)
            }
        case .accessoryCircular, .accessoryRectangular, .accessoryInline:
            Color.clear
        @unknown default:
            Color.clear
        }
    }
#elseif os(macOS)
    var background: Color {
        switch widgetFamily {
        case .systemSmall:
            colorPalette.background
        case .systemMedium:
            colorPalette.background
        case .systemLarge:
            colorPalette.background
        case .systemExtraLarge:
            colorPalette.background
        @unknown default:
            Color.clear
        }
    }
#endif
}

#Preview(as: .systemSmall) {
    Widget()
} timeline: {
    TimelineEntry(date: .now)
}
