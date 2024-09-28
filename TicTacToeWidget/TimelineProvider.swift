import WidgetKit
import SwiftUI

struct TimelineProvider: WidgetKit.TimelineProvider {
    func placeholder(in context: Context) -> TimelineEntry {
        TimelineEntry(date: Date())
    }

    func getSnapshot(in context: Context, completion: @escaping (TimelineEntry) -> ()) {
        let entry = TimelineEntry(date: Date())
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<TimelineEntry>) -> ()) {
        var entries: [TimelineEntry] = []

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = TimelineEntry(date: entryDate)
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}
