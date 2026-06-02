import SwiftData
import SwiftUI

struct ProfileView: View {
    @Query private var statsList: [UserStatsModel]
    @Query private var betsList: [HabitBetModel]

    @Environment(\.modelContext) private var modelContext
    @Environment(\.appTheme) private var theme

    @State private var showResetConfirmation = false

    private var stats: UserStatsModel? {
        statsList.first
    }

    private var totalCompletedBetsCount: Int {
        betsList.filter { $0.isCompleted }.count
    }

    private var wonBetsCount: Int {
        betsList.filter { $0.isCompleted && $0.isSuccessful }.count
    }

    private var lostBetsCount: Int {
        betsList.filter { $0.isCompleted && !$0.isSuccessful }.count
    }

    private var winRate: Double {
        let completed = totalCompletedBetsCount
        guard completed > 0 else { return 0.0 }
        return Double(wonBetsCount) / Double(completed) * 100.0
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // Large Avatar Profile Badge
                VStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(theme.gradient)
                            .frame(width: 100, height: 100)

                        Text(avatarEmoji(for: stats?.activeAvatarId ?? "default"))
                            .font(.system(size: 60))
                    }

                    VStack(spacing: 4) {
                        Text(avatarTitle(for: stats?.activeAvatarId ?? "default"))
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(theme.textColor)

                        Text("ユーザーアカウント")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(theme.cardColor)
                .cornerRadius(20)
                .padding(.horizontal)

                // Stats Dashboard
                VStack(alignment: .leading, spacing: 14) {
                    Text("実績スタッツ")
                        .font(.headline)
                        .foregroundColor(theme.textColor)
                        .padding(.horizontal)

                    VStack(spacing: 10) {
                        statRow(title: "所持チップ", value: "💰 \(stats?.chips ?? 0)")
                        Divider()
                        statRow(title: "合計挑戦数", value: "\(totalCompletedBetsCount) 回")
                        Divider()
                        statRow(title: "成功数", value: "\(wonBetsCount) 回", color: .green)
                        Divider()
                        statRow(title: "失敗数", value: "\(lostBetsCount) 回", color: .red)
                        Divider()
                        statRow(title: "平均勝率", value: String(format: "%.1f%%", winRate))
                    }
                    .padding()
                    .background(theme.cardColor)
                    .cornerRadius(16)
                    .padding(.horizontal)
                }

                // Utilities Block
                VStack(spacing: 12) {
                    // Refill Chips for Testing
                    Button(action: refillChips) {
                        Label("デモチップを獲得 (+200)", systemImage: "plus.circle.fill")
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .cornerRadius(12)
                    }

                    // Reset Button
                    Button(action: { showResetConfirmation = true }) {
                        Label("データを全削除してリセット", systemImage: "trash.fill")
                            .fontWeight(.bold)
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.red.opacity(0.1))
                            .cornerRadius(12)
                    }
                }
                .padding(.horizontal)
                .padding(.top, 10)

                Spacer()
            }
            .padding(.vertical)
            .navigationTitle("プロフィール")
            .background(theme.backgroundColor)
            .confirmationDialog(
                "データを本当にリセットしますか？",
                isPresented: $showResetConfirmation,
                titleVisibility: .visible
            ) {
                Button("すべてのデータを削除する", role: .destructive) {
                    resetData()
                }
                Button("キャンセル", role: .cancel) {}
            } message: {
                Text("この操作は取り消せません。賭け履歴や所持チップ、アンロックしたテーマがすべて初期化されます。")
            }
        }
    }

    private func statRow(title: String, value: String, color: Color? = nil) -> some View {
        HStack {
            Text(title)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .fontWeight(.bold)
                .foregroundColor(color ?? theme.textColor)
        }
        .font(.subheadline)
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

    private func refillChips() {
        guard let userStats = stats else { return }
        HapticService.shared.playSuccess()
        userStats.chips += 200
        try? modelContext.save()
    }

    private func resetData() {
        HapticService.shared.playWarning()

        // Delete all bets
        for bet in betsList {
            modelContext.delete(bet)
        }

        // Delete and reset stats
        for stat in statsList {
            modelContext.delete(stat)
        }

        // Insert fresh starting stats
        let freshStats = UserStatsModel(
            chips: 500,
            totalBetsCount: 0,
            wonBetsCount: 0,
            unlockedThemeIds: ["default"],
            unlockedAvatarIds: ["default"],
            activeThemeId: "default",
            activeAvatarId: "default"
        )
        modelContext.insert(freshStats)

        try? modelContext.save()
    }
}
