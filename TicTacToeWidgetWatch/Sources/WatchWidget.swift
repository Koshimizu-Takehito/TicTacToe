import SwiftUI
import WidgetKit

// MARK: - TimelineEntry

struct TimelineEntry: WidgetKit.TimelineEntry {
    let date: Date
}

// MARK: - TimelineProvider

struct TimelineProvider: WidgetKit.TimelineProvider {
    func placeholder(in _: Context) -> TimelineEntry {
        TimelineEntry(date: .now)
    }

    func getSnapshot(in _: Context, completion: @escaping (TimelineEntry) -> Void) {
        completion(TimelineEntry(date: .now))
    }

    func getTimeline(in _: Context, completion: @escaping (Timeline<Entry>) -> Void) {
        let entries = [TimelineEntry(date: .now)]
        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct TicTacToeWidgetWatchEntryView: View {
    var entry: TimelineProvider.Entry

    var body: some View {
        Text(entry.date, style: .time)
    }
}

@main
struct WatchWidget: SwiftUI.Widget {
    let kind: String = "TicTacToeWidgetWatch"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: TimelineProvider()) { _ in
            ContentView()
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("TicTacToe")
        .description("Let's Play TicTacToe.")
        .supportedFamilies(.supportedFamilies)
    }
}

private extension [WidgetFamily] {
    #if os(watchOS)
        static let supportedFamilies: Self = [
            .accessoryCorner, .accessoryCircular, .accessoryRectangular,
        ]
    #endif
}

#Preview(as: .accessoryRectangular) {
    WatchWidget()
} timeline: {
    TimelineEntry(date: .now)
}
