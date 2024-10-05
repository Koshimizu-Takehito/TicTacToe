import SwiftUI
import TicTacToeWidgetCore
import WidgetKit

// MARK: - TimelineEntry

struct TimelineEntry: WidgetKit.TimelineEntry {
    let date: Date
    let configuration: WidgetConfigurationIntent

    var colorPalette: ColorPalette? {
        (configuration.colorPalette?.id)
            .flatMap(ColorPalette.init(name:))
    }
}

// MARK: - TimelineProvider

struct TimelineProvider: WidgetKit.AppIntentTimelineProvider {
    func placeholder(in _: Context) -> TimelineEntry {
        TimelineEntry(date: .now, configuration: WidgetConfigurationIntent())
    }

    func snapshot(for configuration: WidgetConfigurationIntent, in _: Context) async -> TimelineEntry {
        TimelineEntry(date: .now, configuration: configuration)
    }

    func timeline(for configuration: WidgetConfigurationIntent, in _: Context) async -> Timeline<TimelineEntry> {
        Timeline(entries: [TimelineEntry(date: .now, configuration: configuration)], policy: .atEnd)
    }
}

// MARK: - Widget

struct Widget: SwiftUI.Widget {
    let kind: String = "TicTacToeWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: WidgetConfigurationIntent.self, provider: TimelineProvider()) { entry in
            ContentView(entry: entry)
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
            .accessoryCircular, .accessoryRectangular,
        ]
    #elseif os(macOS)
        static let supportedFamilies: Self = [
            .systemSmall, .systemMedium, .systemLarge,
        ]
    #endif
}

extension WidgetConfigurationIntent {
    static var samples: [WidgetConfigurationIntent] {
        ColorPaletteEntity.allCases.map { entity in
            let intent = WidgetConfigurationIntent()
            intent.colorPalette = entity
            return intent
        }
    }
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
    TimelineEntry(date: .now, configuration: WidgetConfigurationIntent.samples[0])
}
