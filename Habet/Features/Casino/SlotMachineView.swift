import SwiftData
import SwiftUI

struct SlotMachineView: View {
    @Query private var statsList: [UserStatsModel]
    @Environment(\.modelContext) private var modelContext
    @Environment(\.appTheme) private var theme

    @State private var reel1 = "🎰"
    @State private var reel2 = "🎰"
    @State private var reel3 = "🎰"
    @State private var isSpinning = false
    @State private var betAmount = 10
    @State private var outcomeMessage = "ベット額を選択してスピンしてください！"
    @State private var wonChips = 0
    @State private var jackpotUnlocked = false

    private let symbols = ["🎰", "💎", "🔔", "🍒", "🍋", "💩"]
    private let betOptions = [10, 20, 50, 100]

    private var stats: UserStatsModel? {
        statsList.first
    }

    var body: some View {
        VStack(spacing: 20) {
            // Stats Panel
            HStack {
                Text("所持チップ:")
                    .foregroundColor(.secondary)
                Text("💰 \(stats?.chips ?? 0)")
                    .fontWeight(.bold)
                    .foregroundColor(theme.textColor)

                Spacer()
            }
            .padding()
            .background(theme.cardColor)
            .cornerRadius(12)
            .padding(.horizontal)

            // Slot Machine Reels Display
            HStack(spacing: 20) {
                reelCell(symbol: reel1)
                reelCell(symbol: reel2)
                reelCell(symbol: reel3)
            }
            .padding(.vertical, 30)
            .padding(.horizontal, 20)
            .background(Color.black.opacity(0.8))
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(theme.primaryColor, lineWidth: 3)
            )
            .padding(.horizontal)

            // Bet Selector
            VStack(spacing: 10) {
                Text("スピン賭け金")
                    .font(.caption)
                    .foregroundColor(.secondary)

                Picker("ベット額", selection: $betAmount) {
                    ForEach(betOptions, id: \.self) { opt in
                        Text("\(opt)チップ").tag(opt)
                    }
                }
                .pickerStyle(.segmented)
                .disabled(isSpinning)
            }
            .padding(.horizontal)

            // Spin Button
            Button(action: startSpin) {
                Text(isSpinning ? "回転中..." : "スピン！")
                    .font(.title3)
                    .fontWeight(.black)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        isSpinning || (stats?.chips ?? 0) < betAmount
                        ? LinearGradient(colors: [.gray], startPoint: .top, endPoint: .bottom)
                        : theme.gradient
                    )
                    .cornerRadius(16)
                    .shadow(color: theme.primaryColor.opacity(0.4), radius: 8, y: 4)
            }
            .disabled(isSpinning || (stats?.chips ?? 0) < betAmount)
            .padding(.horizontal)

            // Outcome / Payout Table Info
            VStack(spacing: 12) {
                Text(outcomeMessage)
                    .font(.headline)
                    .foregroundColor(wonChips > 0 ? .green : theme.textColor)
                    .multilineTextAlignment(.center)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(theme.cardColor)
                    .cornerRadius(12)

                // Quick rules/odds guide
                payoutsGuide
            }
            .padding(.horizontal)

            Spacer()
        }
        .padding(.vertical)
        .navigationTitle("ラッキースロット")
        .background(theme.backgroundColor)
        .alert("ジャックポット獲得！", isPresented: $jackpotUnlocked) {
            Button("やった！") { jackpotUnlocked = false }
        } message: {
            Text("おめでとうございます！スリーセブンを達成しました！\nショップの「ゴールド VIP」テーマと「ロイヤルチャレンジャー」アバターを無料でアンロックしました！")
        }
    }

    private func reelCell(symbol: String) -> some View {
        Text(symbol)
            .font(.system(size: 64))
            .frame(maxWidth: .infinity)
            .frame(height: 120)
            .background(Color(white: 0.15))
            .cornerRadius(12)
            .shadow(inner: .init(color: .black, radius: 4))
    }

    private var payoutsGuide: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("配当表")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.secondary)

            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("🎰 🎰 🎰 : 100倍")
                    Text("💎 💎 💎 : 50倍")
                    Text("🔔 🔔 🔔 : 20倍")
                }
                Spacer()
                VStack(alignment: .leading, spacing: 4) {
                    Text("🍒 🍒 🍒 : 10倍")
                    Text("🍋 🍋 🍋 : 5倍")
                    Text("任意の2つ一致 : 2倍")
                }
            }
            .font(.system(size: 11))
            .foregroundColor(.secondary)
        }
        .padding()
        .background(theme.cardColor.opacity(0.6))
        .cornerRadius(10)
    }

    private func startSpin() {
        guard let userStats = stats, userStats.chips >= betAmount else { return }

        isSpinning = true
        wonChips = 0
        outcomeMessage = "リールが回転しています..."

        // Deduct bet amount
        userStats.chips -= betAmount
        HapticService.shared.playHeavyImpact()

        var ticks = 0
        let maxTicks = 15

        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
            ticks += 1

            // Shake/randomize reels with incremental stopping
            if ticks <= 6 {
                reel1 = symbols.randomElement()!
                reel2 = symbols.randomElement()!
                reel3 = symbols.randomElement()!
                HapticService.shared.playLightImpact()
            } else if ticks <= 11 {
                reel2 = symbols.randomElement()!
                reel3 = symbols.randomElement()!
                if ticks == 7 { HapticService.shared.playMediumImpact() } // reel 1 stops
            } else if ticks < maxTicks {
                reel3 = symbols.randomElement()!
                if ticks == 12 { HapticService.shared.playMediumImpact() } // reel 2 stops
            }

            if ticks >= maxTicks {
                timer.invalidate()
                reel3 = symbols.randomElement()!
                HapticService.shared.playHeavyImpact() // reel 3 stops
                evaluateResult()
                isSpinning = false
            }
        }
    }

    private func evaluateResult() {
        guard let userStats = stats else { return }

        // Evaluate payout multipliers
        var multiplier = 0
        var isJackpot = false

        if reel1 == reel2 && reel2 == reel3 {
            // Three of a kind
            switch reel1 {
            case "🎰":
                multiplier = 100
                isJackpot = true
            case "💎":
                multiplier = 50
            case "🔔":
                multiplier = 20
            case "🍒":
                multiplier = 10
            case "🍋":
                multiplier = 5
            case "💩":
                multiplier = 0
            default:
                multiplier = 1
            }
        } else if reel1 == reel2 || reel2 == reel3 || reel1 == reel3 {
            // Two of a kind (match 2, but not poop)
            let matchingSymbol = reel1 == reel2 ? reel1 : (reel2 == reel3 ? reel2 : reel1)
            if matchingSymbol == "💩" {
                multiplier = 0
            } else {
                multiplier = 2
            }
        } else {
            // No match
            multiplier = 0
        }

        wonChips = betAmount * multiplier

        if multiplier > 0 {
            userStats.chips += wonChips
            outcomeMessage = "おめでとうございます！\(reel1)\(reel2)\(reel3)で 配当 \(multiplier)倍！\n💰 \(wonChips)チップを獲得しました！"
            HapticService.shared.playSuccess()

            // Special unlocks for Jackpots
            if isJackpot {
                var unlockedNew = false
                if !userStats.unlockedThemeIds.contains("gold") {
                    userStats.unlockedThemeIds.append("gold")
                    unlockedNew = true
                }
                if !userStats.unlockedAvatarIds.contains("crown") {
                    userStats.unlockedAvatarIds.append("crown")
                    unlockedNew = true
                }
                if unlockedNew {
                    jackpotUnlocked = true
                }
            }
        } else {
            if reel1 == "💩" && reel2 == "💩" && reel3 == "💩" {
                outcomeMessage = "最悪！うんち💩が3つ揃ってしまいました！\n運気が下がり、配当はありません。"
            } else {
                outcomeMessage = "残念！ハズレです。\nもう一度挑戦してみましょう！"
            }
            HapticService.shared.playWarning()
        }

        try? modelContext.save()
    }
}
