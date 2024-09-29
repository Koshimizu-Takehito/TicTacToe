import WidgetKit
import SwiftUI

@main
struct WidgetBundle: SwiftUI.WidgetBundle {
    var body: some SwiftUI.Widget {
        Widget()
    }
}

// MARK: - Widget
struct Widget: SwiftUI.Widget {
    let kind: String = "TicTacToeWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: TimelineProvider()) { _ in
            GameBoardView()
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .contentMarginsDisabled()
        .configurationDisplayName("TicTacToe")
        .description("Let's Play TicTacToe.")
        .supportedFamilies(.supportedFamilies)
    }
}

private extension [WidgetFamily] {
#if os(iOS)
    static let supportedFamilies: Self = [
        .systemSmall, .systemMedium, .systemLarge,
        .accessoryCircular, .accessoryRectangular
    ]
#elseif os(macOS)
    static let supportedFamilies: Self = [
        .systemSmall, .systemMedium, .systemLarge,
    ]
#endif
}

#Preview(as: .systemSmall) {
    Widget()
} timeline: {
    TimelineEntry(date: .now)
}
