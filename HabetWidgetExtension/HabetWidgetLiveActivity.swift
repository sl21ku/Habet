#if canImport(ActivityKit) && !targetEnvironment(macCatalyst)
import ActivityKit
import WidgetKit
import SwiftUI

struct HabetWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: HabetWidgetAttributes.self) { context in
            // Lock Screen and Notification Banner UI
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Label("Habet 挑戦中", systemImage: "bolt.fill")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)

                    Spacer()

                    Text("賭け金: 💰 \(context.state.chipsWagered)")
                        .font(.caption)
                        .fontWeight(.bold)
                }

                HStack {
                    Text(context.state.habitName)
                        .font(.headline)
                        .fontWeight(.bold)

                    Spacer()

                    // Native ticking countdown timer on Lock Screen
                    Text(context.state.targetEndDate, style: .timer)
                        .font(.title3)
                        .fontWeight(.black)
                        .fontDesign(.monospaced)
                        .foregroundColor(.red)
                }
            }
            .padding()
            .activityBackgroundTint(Color(white: 0.12))
            .activitySystemActionForegroundColor(.white)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded Dynamic Island
                DynamicIslandExpandedRegion(.leading) {
                    Label("Habet", systemImage: "dice.fill")
                        .font(.caption)
                        .foregroundColor(.blue)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text(context.state.targetEndDate, style: .timer)
                        .font(.headline)
                        .fontWeight(.bold)
                        .fontDesign(.monospaced)
                        .foregroundColor(.red)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(context.state.habitName)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        Text("賭け金: 💰 \(context.state.chipsWagered) / 所持: 💰 \(context.attributes.totalChips)")
                            .font(.system(size: 10))
                            .foregroundColor(.secondary)
                    }
                }
            } compactLeading: {
                Text("🎯")
            } compactTrailing: {
                Text(context.state.targetEndDate, style: .timer)
                    .font(.caption2)
                    .fontWeight(.bold)
                    .foregroundColor(.red)
            } minimal: {
                Text("🎯")
            }
        }
    }
}
#endif
