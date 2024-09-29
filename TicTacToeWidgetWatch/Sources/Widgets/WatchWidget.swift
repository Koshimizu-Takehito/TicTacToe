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

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let entries = [TimelineEntry(date: .now)]
        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct TicTacToeWidgetWatchEntryView : View {
    var entry: TimelineProvider.Entry

    var body: some View {
        Text(entry.date, style: .time)
    }
}

@main
struct WatchWidget: SwiftUI.Widget {
    let kind: String = "TicTacToeWidgetWatch"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: TimelineProvider()) { entry in
            GameBoardView()
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
        .accessoryCorner, .accessoryCircular, .accessoryRectangular
    ]
#endif
}

#Preview(as: .accessoryRectangular) {
    WatchWidget()
} timeline: {
    TimelineEntry(date: .now)
}
