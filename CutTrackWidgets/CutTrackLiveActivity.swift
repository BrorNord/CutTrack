import ActivityKit
import WidgetKit
import SwiftUI

struct CutTrackLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: CutTrackActivityAttributes.self) { context in
            HStack {
                VStack(alignment: .leading) {
                    Text("CutTrack Extreme").font(.headline)
                    Text("\(context.state.remainingFood) food kcal remaining").foregroundStyle(.secondary)
                }
                Spacer()
                VStack(alignment: .trailing) {
                    Label("\(context.state.activeCalories)", systemImage: "flame.fill")
                    Text("active kcal").font(.caption2)
                }
            }
            .padding()
            .activityBackgroundTint(.black)
            .activitySystemActionForegroundColor(.green)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    Label("\(context.state.foodCalories)", systemImage: "fork.knife")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Label("\(context.state.activeCalories)", systemImage: "flame.fill")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    SwiftUI.ProgressView(value: Double(context.state.activeCalories), total: 900).tint(.green)
                }
            } compactLeading: {
                Image(systemName: "flame.fill").foregroundStyle(.green)
            } compactTrailing: {
                Text("\(context.state.activeCalories)")
            } minimal: {
                Image(systemName: "flame.fill").foregroundStyle(.green)
            }
        }
    }
}
