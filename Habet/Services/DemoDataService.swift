import Foundation
import SwiftData

enum DemoDataService {
    static func seedIfNeeded(modelContext: ModelContext) {
        let statsDescriptor = FetchDescriptor<UserStatsModel>()
        do {
            let statsList = try modelContext.fetch(statsDescriptor)
            if statsList.isEmpty {
                // Insert default stats
                let newStats = UserStatsModel(
                    chips: 500,
                    totalBetsCount: 3,
                    wonBetsCount: 2,
                    unlockedThemeIds: ["default", "neon"],
                    unlockedAvatarIds: ["default", "glasses"],
                    activeThemeId: "default",
                    activeAvatarId: "default"
                )
                modelContext.insert(newStats)

                // Insert some historical completed/failed bets
                let calendar = Calendar.current
                let now = Date()

                let bet1 = HabitBetModel(
                    habitName: "早起き (7時前起床)",
                    betAmount: 50,
                    odds: 1.5,
                    startDate: calendar.date(byAdding: .day, value: -2, to: now)!,
                    endDate: calendar.date(byAdding: .day, value: -2, to: now)!,
                    isCompleted: true,
                    isSuccessful: true
                )

                let bet2 = HabitBetModel(
                    habitName: "英語勉強 30分",
                    betAmount: 100,
                    odds: 2.0,
                    startDate: calendar.date(byAdding: .day, value: -1, to: now)!,
                    endDate: calendar.date(byAdding: .day, value: -1, to: now)!,
                    isCompleted: true,
                    isSuccessful: false
                )

                let bet3 = HabitBetModel(
                    habitName: "ジムで筋トレ 45分",
                    betAmount: 150,
                    odds: 1.8,
                    startDate: calendar.date(byAdding: .hour, value: -5, to: now)!,
                    endDate: calendar.date(byAdding: .hour, value: -4, to: now)!,
                    isCompleted: true,
                    isSuccessful: true
                )

                modelContext.insert(bet1)
                modelContext.insert(bet2)
                modelContext.insert(bet3)

                try modelContext.save()
            }
        } catch {
            print("Failed to seed demo data: \(error)")
        }
    }
}
