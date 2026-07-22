import WidgetKit
import SwiftUI
import ActivityKit

@main
struct CutTrackWidgets: WidgetBundle {
    var body: some Widget {
        CutTrackWidget()
        CutTrackLiveActivity()
    }
}

struct CutTrackWidget: Widget {
    let kind = "CutTrackWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            VStack(alignment: .leading, spacing: 8) {
                Text("CUTTRACK").font(.caption.bold()).tracking(2)
                Text("Extreme").font(.title2.bold())
                Spacer()
                HStack {
                    Label("\(entry.food) / 1,894", systemImage: "fork.knife")
                    Spacer()
                    Label("\(entry.active) / 900", systemImage: "flame.fill")
                }
                .font(.caption.bold())
            }
            .padding()
            .containerBackground(.black, for: .widget)
            .foregroundStyle(.white)
        }
        .configurationDisplayName("CutTrack Today")
        .description("See your food and active-calorie progress.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

struct Entry: TimelineEntry {
    let date: Date
    let food: Int
    let active: Int
}

struct Provider: TimelineProvider {
    let defaults = UserDefaults(suiteName: "group.dk.blbit.cuttrack")

    func placeholder(in context: Context) -> Entry {
        Entry(date: .now, food: 1120, active: 640)
    }

    func getSnapshot(in context: Context, completion: @escaping (Entry) -> Void) {
        completion(current())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> Void) {
        completion(Timeline(entries: [current()], policy: .after(.now.addingTimeInterval(30 * 60))))
    }

    private func current() -> Entry {
        Entry(
            date: .now,
            food: defaults?.integer(forKey: "food") ?? 0,
            active: defaults?.integer(forKey: "active") ?? 0
        )
    }
}
