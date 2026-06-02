import ActivityKit
import Foundation

struct HabetWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic state that changes during the activity
        var habitName: String
        var chipsWagered: Int
        var targetEndDate: Date
    }

    // Static properties that do not change
    var totalChips: Int
}
