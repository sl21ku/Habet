import WidgetKit
import SwiftUI
import SwiftData

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), chips: 500, winRate: 60.0)
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), chips: 500, winRate: 60.0)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<SimpleEntry>) -> ()) {
        // Set up the SwiftData ModelContainer sharing the app group
        let container = try? ModelContainer(
            for: Schema([UserStatsModel.self]),
            configurations: [ModelConfiguration(groupContainer: .identifier("group.com.sl21ku.Habet"))]
        )

        var chips = 500
        var winRate = 0.0

        if let container = container {
            let context = ModelContext(container)
            let descriptor = FetchDescriptor<UserStatsModel>()
            if let stats = try? context.fetch(descriptor).first {
                chips = stats.chips
                if stats.totalBetsCount > 0 {
                    winRate = Double(stats.wonBetsCount) / Double(stats.totalBetsCount) * 100.0
                }
            }
        }

        let entry = SimpleEntry(date: Date(), chips: chips, winRate: winRate)
        let timeline = Timeline(entries: [entry], policy: .atEnd)
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let chips: Int
    let winRate: Double
}

struct HabetWidgetEntryView: View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var family

    var body: some View {
        if family == .accessoryRectangular {
            VStack(alignment: .leading, spacing: 2) {
                Text("Habet Status")
                    .font(.caption2)
                    .fontWeight(.bold)
                HStack(spacing: 2) {
                    Text("💰")
                    Text("\(entry.chips)")
                        .fontWeight(.bold)
                }
                Text("勝率: \(String(format: "%.0f%%", entry.winRate))")
                    .font(.system(size: 9))
            }
        } else {
            VStack(alignment: .leading, spacing: 6) {
                Text("Habet")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.blue)

                Spacer()

                HStack(spacing: 2) {
                    Text("💰")
                    Text("\(entry.chips)")
                        .font(.title3)
                        .fontWeight(.bold)
                }

                Text("勝率: \(String(format: "%.1f%%", entry.winRate))")
                    .font(.system(size: 10))
                    .foregroundColor(.secondary)
            }
            .padding(4)
        }
    }
}

struct HabetWidget: Widget {
    let kind: String = "HabetWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            HabetWidgetEntryView(entry: entry)
                .containerBackground(.fill.ternary, for: .widget)
        }
        .configurationDisplayName("Habet Widget")
        .description("現在の所持チップと勝率を表示します。")
        .supportedFamilies([.systemSmall, .accessoryRectangular])
    }
}

@main
struct HabetWidgetBundle: WidgetBundle {
    var body: some Widget {
        HabetWidget()
        HabetWidgetLiveActivity()
    }
}
