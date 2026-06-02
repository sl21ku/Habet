import ActivityKit
import Foundation

final class ActivityService {
    static let shared = ActivityService()

    private init() {}

    private var activeActivity: Any? // Keep it type-erased to prevent strict dependency issues in unit tests if needed, but we cast it internally

    func startLiveActivity(habitName: String, chipsWagered: Int, totalChips: Int, durationSeconds: Double) {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else { return }

        // End any existing live activity first
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
                content: .init(state: initialContentState, staleDate: nil),
                pushType: nil
            )
            self.activeActivity = activity
            print("Successfully started Live Activity: \(activity.id)")
        } catch {
            print("Error starting Live Activity: \(error.localizedDescription)")
        }
    }

    func updateLiveActivity(habitName: String, chipsWagered: Int, targetEndDate: Date) {
        guard let activity = activeActivity as? Activity<HabetWidgetAttributes> else { return }

        let updatedState = HabetWidgetAttributes.ContentState(
            habitName: habitName,
            chipsWagered: chipsWagered,
            targetEndDate: targetEndDate
        )

        Task {
            await activity.update(.init(state: updatedState, staleDate: nil))
            print("Updated Live Activity: \(activity.id)")
        }
    }

    func endLiveActivity() {
        guard let activity = activeActivity as? Activity<HabetWidgetAttributes> else { return }

        let finalState = HabetWidgetAttributes.ContentState(
            habitName: "終了",
            chipsWagered: 0,
            targetEndDate: Date()
        )

        Task {
            await activity.end(.init(state: finalState, staleDate: nil), dismissalPolicy: .immediate)
            self.activeActivity = nil
            print("Ended Live Activity: \(activity.id)")
        }
    }
}
