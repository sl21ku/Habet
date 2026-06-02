import SwiftData
import SwiftUI

struct BetSetupView: View {
    @Binding var selectedTab: Int

    @Query(filter: #Predicate<HabitBetModel> { !$0.isCompleted })
    private var activeBets: [HabitBetModel]

    @Query private var statsList: [UserStatsModel]

    @Environment(\.modelContext) private var modelContext
    @Environment(\.appTheme) private var theme

    @State private var habitName = ""
    @State private var betAmountString = "100"
    @State private var durationMinutes = 30
    @State private var difficulty: Difficulty = .medium

    private enum Difficulty: String, CaseIterable, Identifiable {
        case easy = "easy"
        case medium = "medium"
        case hard = "hard"

        var id: String { self.rawValue }

        var displayName: String {
            switch self {
            case .easy: return "イージー"
            case .medium: return "ノーマル"
            case .hard: return "ハード"
            }
        }

        var odds: Double {
            switch self {
            case .easy: return 1.5
            case .medium: return 2.0
            case .hard: return 3.0
            }
        }
    }

    private var stats: UserStatsModel? {
        statsList.first
    }

    private var isBetActive: Bool {
        !activeBets.isEmpty
    }

    private let durationOptions = [1, 5, 10, 30, 45, 60, 120]

    var body: some View {
        NavigationStack {
            Form {
                if isBetActive {
                    Section {
                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(.orange)
                                Text("ベット挑戦中です")
                                    .fontWeight(.bold)
                            }

                            Text("現在アクティブなベットが既に存在します。新しいベットを行う前に、現在のベットを完了またはギブアップしてください。")
                                .font(.caption)
                                .foregroundColor(.secondary)

                            Button(action: {
                                HapticService.shared.playSelection()
                                selectedTab = 0
                            }) {
                                Text("挑戦中の画面に戻る")
                                    .font(.subheadline)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 8)
                                    .background(theme.gradient)
                                    .cornerRadius(8)
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(.vertical, 4)
                    }
                } else {
                    Section("習慣プリセット") {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                presetButton(title: "早起き", icon: "sun.max.fill", name: "7時前に起床して行動する", duration: 15, diff: .easy)
                                presetButton(title: "読書 30分", icon: "book.fill", name: "集中して本を30分間読む", duration: 30, diff: .medium)
                                presetButton(title: "筋トレ", icon: "dumbbell.fill", name: "スクワット&腕立て伏せ", duration: 10, diff: .medium)
                                presetButton(title: "高速テスト (1分)", icon: "sparkles", name: "1分間だけの動作テスト！", duration: 1, diff: .hard)
                            }
                            .padding(.vertical, 4)
                        }
                    }

                    Section("ベット設定") {
                        TextField("習慣・目標（例: 30分勉強する）", text: $habitName)
                            .textInputAutocapitalization(.never)

                        Picker("制限時間", selection: $durationMinutes) {
                            ForEach(durationOptions, id: \.self) { min in
                                Text("\(min)分").tag(min)
                            }
                        }

                        Picker("難易度 (オッズ)", selection: $difficulty) {
                            ForEach(Difficulty.allCases) { diff in
                                Text("\(diff.displayName) (\(String(format: "%.1fx", diff.odds)))").tag(diff)
                            }
                        }
                        .pickerStyle(.segmented)
                    }

                    Section("賭けチップ") {
                        HStack {
                            Text("💰")
                            TextField("賭ける枚数", text: $betAmountString)
                                .keyboardType(.numberPad)
                        }

                        if let userStats = stats {
                            HStack {
                                Text("所持チップ: 💰 \(userStats.chips)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Spacer()
                            }

                            HStack(spacing: 12) {
                                quickBetButton(amount: 50)
                                quickBetButton(amount: 100)
                                quickBetButton(amount: 200)
                                Button(action: {
                                    HapticService.shared.playSelection()
                                    betAmountString = "\(userStats.chips)"
                                }) {
                                    Text("全賭け")
                                        .font(.caption)
                                        .fontWeight(.bold)
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 6)
                                        .background(Color.red.opacity(0.1))
                                        .foregroundColor(.red)
                                        .cornerRadius(6)
                                }
                                .buttonStyle(.plain)
                            }
                            .padding(.vertical, 4)
                        }
                    }

                    Section {
                        Button(action: placeBet) {
                            Text("チップを賭けて挑戦開始！")
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity, alignment: .center)
                        }
                        .disabled(habitName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || Int(betAmountString) == nil || (Int(betAmountString) ?? 0) <= 0 || (Int(betAmountString) ?? 0) > (stats?.chips ?? 0))
                        .listRowBackground(
                            (habitName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || Int(betAmountString) == nil || (Int(betAmountString) ?? 0) <= 0 || (Int(betAmountString) ?? 0) > (stats?.chips ?? 0))
                            ? Color.gray.opacity(0.3)
                            : nil
                        )
                        .listRowBackground(theme.gradient)
                    }
                }
            }
            .navigationTitle("ベット設定")
            .background(theme.backgroundColor)
        }
    }

    private func presetButton(title: String, icon: String, name: String, duration: Int, diff: Difficulty) -> some View {
        Button(action: {
            HapticService.shared.playSelection()
            habitName = name
            durationMinutes = duration
            difficulty = diff
        }) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                Text(title)
                    .font(.caption)
                    .fontWeight(.semibold)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(theme.cardColor)
            .foregroundColor(theme.primaryColor)
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(theme.primaryColor.opacity(0.3), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }

    private func quickBetButton(amount: Int) -> some View {
        Button(action: {
            HapticService.shared.playSelection()
            betAmountString = "\(amount)"
        }) {
            Text("+\(amount)")
                .font(.caption)
                .fontWeight(.semibold)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(theme.cardColor)
                .foregroundColor(theme.textColor)
                .cornerRadius(6)
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(Color.secondary.opacity(0.3), lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
    }

    private func placeBet() {
        guard let userStats = stats,
              let betAmount = Int(betAmountString),
              betAmount > 0,
              betAmount <= userStats.chips,
              !habitName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return
        }

        // Deduct chips
        userStats.chips -= betAmount

        // Create new habit bet
        let seconds = Double(durationMinutes * 60)
        let endDate = Date().addingTimeInterval(seconds)

        let newBet = HabitBetModel(
            habitName: habitName,
            betAmount: betAmount,
            odds: difficulty.odds,
            startDate: Date(),
            endDate: endDate
        )

        modelContext.insert(newBet)

        // Start Live Activity
        ActivityService.shared.startLiveActivity(
            habitName: habitName,
            chipsWagered: betAmount,
            totalChips: userStats.chips,
            durationSeconds: seconds
        )

        HapticService.shared.playHeavyImpact()

        do {
            try modelContext.save()
            // Reset input fields
            habitName = ""
            betAmountString = "100"
            // Transition back to Home
            selectedTab = 0
        } catch {
            print("Failed to save placed bet: \(error)")
        }
    }
}
