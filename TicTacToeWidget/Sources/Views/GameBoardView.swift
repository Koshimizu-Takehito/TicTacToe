import SwiftUI
import WidgetKit

struct GameBoardView: View {
    @Environment(\.widgetFamily) var widgetFamily
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
            .background(background, in: .rect)
        }
    }
}

private extension GameBoardView {
#if os(iOS)
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
        case .accessoryCircular:
            Color.clear
        case .accessoryRectangular:
            Color.clear
        case .accessoryInline:
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