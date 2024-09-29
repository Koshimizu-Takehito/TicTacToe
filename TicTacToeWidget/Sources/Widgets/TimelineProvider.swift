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
