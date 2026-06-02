import XCTest
import SwiftData
@testable import Habet

final class HabetTests: XCTestCase {

    func testUserStatsInitialization() {
        let stats = UserStatsModel(
            chips: 500,
            totalBetsCount: 0,
            wonBetsCount: 0,
            unlockedThemeIds: ["default"],
            unlockedAvatarIds: ["default"],
            activeThemeId: "default",
            activeAvatarId: "default"
        )

        XCTAssertEqual(stats.chips, 500)
        XCTAssertEqual(stats.totalBetsCount, 0)
        XCTAssertEqual(stats.wonBetsCount, 0)
        XCTAssertEqual(stats.activeThemeId, "default")
        XCTAssertEqual(stats.activeAvatarId, "default")
    }

    func testHabitBetInitialization() {
        let now = Date()
        let deadline = now.addingTimeInterval(3600)
        let bet = HabitBetModel(
            habitName: "英語を勉強する",
            betAmount: 100,
            odds: 2.0,
            startDate: now,
            endDate: deadline
        )

        XCTAssertEqual(bet.habitName, "英語を勉強する")
        XCTAssertEqual(bet.betAmount, 100)
        XCTAssertEqual(bet.odds, 2.0)
        XCTAssertEqual(bet.startDate, now)
        XCTAssertEqual(bet.endDate, deadline)
        XCTAssertFalse(bet.isCompleted)
        XCTAssertFalse(bet.isSuccessful)
    }

    func testBlackjackScoreCalculation() {
        // Test 1: Simple numeric hand
        let hand1 = [
            BlackjackView.Card(suit: "♠️", value: 2),
            BlackjackView.Card(suit: "♥️", value: 5)
        ]
        XCTAssertEqual(BlackjackView.calculateScore(hand: hand1), 7)

        // Test 2: Face card value
        let hand2 = [
            BlackjackView.Card(suit: "♦️", value: 10),
            BlackjackView.Card(suit: "♣️", value: 12) // Queen
        ]
        XCTAssertEqual(BlackjackView.calculateScore(hand: hand2), 20)

        // Test 3: Ace as 11
        let hand3 = [
            BlackjackView.Card(suit: "♠️", value: 1), // Ace
            BlackjackView.Card(suit: "♥️", value: 9)
        ]
        XCTAssertEqual(BlackjackView.calculateScore(hand: hand3), 20)

        // Test 4: Ace reduction (Aces drop to 1 to avoid bust)
        let hand4 = [
            BlackjackView.Card(suit: "♠️", value: 1), // Ace
            BlackjackView.Card(suit: "♦️", value: 1), // Ace
            BlackjackView.Card(suit: "♣️", value: 11) // Jack
        ]
        XCTAssertEqual(BlackjackView.calculateScore(hand: hand4), 12)
    }
}
