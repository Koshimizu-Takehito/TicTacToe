import WidgetKit
import SwiftUI

// MARK: - TimelineEntry

struct TimelineEntry: WidgetKit.TimelineEntry {
    let date: Date
}

// MARK: - TimelineProvider

struct TimelineProvider: WidgetKit.TimelineProvider {
    func placeholder(in context: Context) -> TimelineEntry {
        TimelineEntry(date: .now)
    }

    func getSnapshot(in context: Context, completion: @escaping (TimelineEntry) -> ()) {
        completion(TimelineEntry(date: .now))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<TimelineEntry>) -> ()) {
        let entries = [TimelineEntry(date: .now)]
        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

// MARK: - Widget
struct Widget: SwiftUI.Widget {
    let kind: String = "TicTacToeWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: TimelineProvider()) { _ in
            ContentView()
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

@main
struct WidgetBundle: SwiftUI.WidgetBundle {
    var body: some SwiftUI.Widget {
        Widget()
    }
}

#Preview(as: .systemSmall) {
    Widget()
} timeline: {
    TimelineEntry(date: .now)
}
