import Foundation
import SwiftData

@Model
final class HabitBetModel {
    @Attribute(.unique) var id: UUID
    var habitName: String
    var betAmount: Int
    var odds: Double
    var startDate: Date
    var endDate: Date
    var isCompleted: Bool
    var isSuccessful: Bool
    var completionPhotoData: Data?

    init(
        id: UUID = UUID(),
        habitName: String,
        betAmount: Int,
        odds: Double,
        startDate: Date = Date(),
        endDate: Date,
        isCompleted: Bool = false,
        isSuccessful: Bool = false,
        completionPhotoData: Data? = nil
    ) {
        self.id = id
        self.habitName = habitName
        self.betAmount = betAmount
        self.odds = odds
        self.startDate = startDate
        self.endDate = endDate
        self.isCompleted = isCompleted
        self.isSuccessful = isSuccessful
        self.completionPhotoData = completionPhotoData
    }
}
