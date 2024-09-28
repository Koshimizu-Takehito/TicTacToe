import WidgetKit
import SwiftUI

struct TimelineEntry: WidgetKit.TimelineEntry {
    let date: Date
}

struct WidgetEntryView : View {
    var entry: TimelineEntry

    var body: some View {
        VStack {
            HStack {
                Text(entry.date, style: .time)
            }
        }
    }
}

struct Widget: SwiftUI.Widget {
    let kind: String = "TicTacToeWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: TimelineProvider()) { entry in
            if #available(macOS 14.0, iOS 17.0, *) {
                WidgetEntryView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
            } else {
                WidgetEntryView(entry: entry)
                    .padding()
                    .background()
            }
        }
        .configurationDisplayName("TicTacToe")
        .description("Let's Play TicTacToe.")
    }
}

#Preview(as: .systemSmall) {
    Widget()
} timeline: {
    TimelineEntry(date: .now)
    TimelineEntry(date: .now)
}
