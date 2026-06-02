import SwiftData
import SwiftUI

struct HomeView: View {
    @Binding var selectedTab: Int

    @Query(sort: \HabitBetModel.endDate, order: .reverse)
    private var allBets: [HabitBetModel]

    @Query private var statsList: [UserStatsModel]

    private var activeBets: [HabitBetModel] {
        allBets.filter { !$0.isCompleted }
    }

    private var completedBets: [HabitBetModel] {
        allBets.filter { $0.isCompleted }
    }

    @Environment(\.appTheme) private var theme

    private var stats: UserStatsModel? {
        statsList.first
    }

    private var winRate: Double {
        guard let stats = stats, stats.totalBetsCount > 0 else { return 0.0 }
        return Double(stats.wonBetsCount) / Double(stats.totalBetsCount) * 100.0
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Header Card
                    headerSection

                    // Chips and stats summary
                    statsSummarySection

                    // Active Bet Section
                    VStack(alignment: .leading, spacing: 10) {
                        Text("挑戦中のベット")
                            .font(.headline)
                            .foregroundColor(theme.textColor)
                            .padding(.horizontal)

                        if let activeBet = activeBets.first, let userStats = stats {
                            ActiveBetCard(bet: activeBet, stats: userStats)
                                .padding(.horizontal)
                        } else {
                            noActiveBetCard
                                .padding(.horizontal)
                        }
                    }

                    // Completed Bets History
                    VStack(alignment: .leading, spacing: 10) {
                        Text("履歴")
                            .font(.headline)
                            .foregroundColor(theme.textColor)
                            .padding(.horizontal)

                        if completedBets.isEmpty {
                            VStack(spacing: 12) {
                                Image(systemName: "clock.badge.questionmark")
                                    .font(.system(size: 32))
                                    .foregroundColor(.secondary)
                                Text("ベット履歴はありません")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 30)
                            .background(theme.cardColor)
                            .cornerRadius(12)
                            .padding(.horizontal)
                        } else {
                            VStack(spacing: 12) {
                                ForEach(completedBets.prefix(10)) { bet in
                                    historyRow(for: bet)
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("Habet")
            .background(theme.backgroundColor)
        }
    }

    private var headerSection: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(theme.gradient)
                    .frame(width: 60, height: 60)

                Text(avatarEmoji(for: stats?.activeAvatarId ?? "default"))
                    .font(.system(size: 36))
            }

            VStack(alignment: .leading, spacing: 4) {
                Text("プレイヤー")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(avatarTitle(for: stats?.activeAvatarId ?? "default"))
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(theme.textColor)
            }

            Spacer()
        }
        .padding()
        .background(theme.cardColor)
        .cornerRadius(16)
        .padding(.horizontal)
    }

    private var statsSummarySection: some View {
        HStack(spacing: 16) {
            // Chip balance card
            VStack(spacing: 6) {
                Text("所持チップ")
                    .font(.caption)
                    .foregroundColor(.secondary)

                HStack(spacing: 4) {
                    Text("💰")
                    Text("\(stats?.chips ?? 0)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(theme.textColor)
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(theme.cardColor)
            .cornerRadius(12)

            // Win rate card
            VStack(spacing: 6) {
                Text("勝率")
                    .font(.caption)
                    .foregroundColor(.secondary)

                Text(String(format: "%.1f%%", winRate))
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(theme.textColor)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(theme.cardColor)
            .cornerRadius(12)
        }
        .padding(.horizontal)
    }

    private var noActiveBetCard: some View {
        VStack(spacing: 16) {
            Image(systemName: "checkmark.circle.badge.questionmark")
                .font(.system(size: 40))
                .foregroundColor(theme.accentColor)

            VStack(spacing: 4) {
                Text("現在挑戦中の習慣はありません")
                    .font(.headline)
                    .foregroundColor(theme.textColor)
                Text("習慣にチップを賭けて、モチベーションを高めましょう！")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }

            Button(action: {
                HapticService.shared.playSelection()
                selectedTab = 1
            }) {
                Text("習慣にベットする")
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(theme.gradient)
                    .cornerRadius(20)
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(theme.cardColor)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.secondary.opacity(0.2), lineWidth: 1)
        )
    }

    private func historyRow(for bet: HabitBetModel) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(bet.habitName)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(theme.textColor)

                Text(bet.endDate.formatted(date: .abbreviated, time: .shortened))
                    .font(.system(size: 10))
                    .foregroundColor(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                if bet.isSuccessful {
                    Text("成功")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Color.green.opacity(0.1))
                        .cornerRadius(6)

                    Text("+💰 \(Int(Double(bet.betAmount) * bet.odds))")
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                } else {
                    Text("失敗")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.red)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(6)

                    Text("-💰 \(bet.betAmount)")
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(.red)
                }
            }
        }
        .padding()
        .background(theme.cardColor)
        .cornerRadius(12)
    }

    private func avatarEmoji(for id: String) -> String {
        switch id {
        case "crown": return "👑"
        case "glasses": return "😎"
        case "cat": return "🐱"
        default: return "👤"
        }
    }

    private func avatarTitle(for id: String) -> String {
        switch id {
        case "crown": return "ロイヤルチャレンジャー"
        case "glasses": return "ハイローラー"
        case "cat": return "ラッキーキャット"
        default: return "ビギナー"
        }
    }
}
