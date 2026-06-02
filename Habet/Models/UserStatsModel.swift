import Foundation
import SwiftData

@Model
final class UserStatsModel {
    var chips: Int
    var totalBetsCount: Int
    var wonBetsCount: Int
    var unlockedThemeIds: [String]
    var unlockedAvatarIds: [String]
    var activeThemeId: String
    var activeAvatarId: String

    init(
        chips: Int = 500,
        totalBetsCount: Int = 0,
        wonBetsCount: Int = 0,
        unlockedThemeIds: [String] = ["default"],
        unlockedAvatarIds: [String] = ["default"],
        activeThemeId: String = "default",
        activeAvatarId: String = "default"
    ) {
        self.chips = chips
        self.totalBetsCount = totalBetsCount
        self.wonBetsCount = wonBetsCount
        self.unlockedThemeIds = unlockedThemeIds
        self.unlockedAvatarIds = unlockedAvatarIds
        self.activeThemeId = activeThemeId
        self.activeAvatarId = activeAvatarId
    }
}
