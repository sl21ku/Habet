#if canImport(ActivityKit)
import ActivityKit
#endif
import Foundation

final class ActivityService {
    static let shared = ActivityService()

    private init() {}

    private var activeActivity: Any?

    func startLiveActivity(habitName: String, chipsWagered: Int, totalChips: Int, durationSeconds: Double) {
        #if canImport(ActivityKit)
        guard ActivityAuthorizationInfo().areActivitiesEnabled else { return }

        endLiveActivity()

        let attributes = HabetWidgetAttributes(totalChips: totalChips)
        let initialContentState = HabetWidgetAttributes.ContentState(
            habitName: habitName,
            chipsWagered: chipsWagered,
            targetEndDate: Date().addingTimeInterval(durationSeconds)
        )

        do {
            let activity = try Activity.request(
                attributes: attributes,
                content: ActivityContent<HabetWidgetAttributes.ContentState>(state: initialContentState, staleDate: nil),
                pushType: nil
            )
            self.activeActivity = activity
            print("Successfully started Live Activity: \(activity.id)")
        } catch {
            print("Error starting Live Activity: \(error.localizedDescription)")
        }
        #endif
    }

    func updateLiveActivity(habitName: String, chipsWagered: Int, targetEndDate: Date) {
        #if canImport(ActivityKit)
        guard let activity = activeActivity as? Activity<HabetWidgetAttributes> else { return }

        let updatedState = HabetWidgetAttributes.ContentState(
            habitName: habitName,
            chipsWagered: chipsWagered,
            targetEndDate: targetEndDate
        )

        Task {
            await activity.update(ActivityContent(state: updatedState, staleDate: nil))
            print("Updated Live Activity: \(activity.id)")
        }
        #endif
    }

    func endLiveActivity() {
        #if canImport(ActivityKit)
        guard let activity = activeActivity as? Activity<HabetWidgetAttributes> else { return }

        let finalState = HabetWidgetAttributes.ContentState(
            habitName: "終了",
            chipsWagered: 0,
            targetEndDate: Date()
        )

        Task {
            await activity.end(ActivityContent(state: finalState, staleDate: nil), dismissalPolicy: .immediate)
            self.activeActivity = nil
            print("Ended Live Activity: \(activity.id)")
        }
        #endif
    }
}
