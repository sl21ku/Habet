import SwiftData
import SwiftUI

struct BlackjackView: View {
    @Query private var statsList: [UserStatsModel]
    @Environment(\.modelContext) private var modelContext
    @Environment(\.appTheme) private var theme

    // Game state
    @State private var gameState: GameState = .betting
    @State private var deck: [Card] = []
    @State private var playerHand: [Card] = []
    @State private var dealerHand: [Card] = []
    @State private var betAmount = 20
    @State private var activeWager = 0
    @State private var statusMessage = "ベット額を選んでカードを配ってください！"
    @State private var payoutResult = ""

    private let betOptions = [10, 25, 50, 100]

    private var stats: UserStatsModel? {
        statsList.first
    }

    enum GameState {
        case betting
        case playerTurn
        case dealerTurn
        case gameOver
    }

    struct Card: Identifiable, Equatable {
        let id = UUID()
        let suit: String // ♠️, ♥️, ♦️, ♣️
        let value: Int // 1 (Ace) to 13 (King)

        var displayValue: String {
            switch value {
            case 1: return "A"
            case 11: return "J"
            case 12: return "Q"
            case 13: return "K"
            default: return "\(value)"
            }
        }

        var isRed: Bool {
            suit == "♥️" || suit == "♦️"
        }
    }

    var body: some View {
        VStack(spacing: 16) {
            // Stats Panel
            HStack {
                Text("所持チップ:")
                    .foregroundColor(.secondary)
                Text("💰 \(stats?.chips ?? 0)")
                    .fontWeight(.bold)
                    .foregroundColor(theme.textColor)

                Spacer()

                if gameState != .betting {
                    Text("ベット中:")
                        .foregroundColor(.secondary)
                    Text("💰 \(activeWager)")
                        .fontWeight(.bold)
                        .foregroundColor(theme.primaryColor)
                }
            }
            .padding()
            .background(theme.cardColor)
            .cornerRadius(12)
            .padding(.horizontal)

            // Table felt green color area
            VStack(spacing: 20) {
                // Dealer Area
                VStack(spacing: 8) {
                    Text("ディーラーの点数: \(dealerScoreDisplay)")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    HStack(spacing: 10) {
                        if dealerHand.isEmpty {
                            cardPlaceholder
                        } else {
                            ForEach(0..<dealerHand.count, id: \.self) { index in
                                if gameState == .playerTurn && index == 1 {
                                    cardBack
                                } else {
                                    cardView(card: dealerHand[index])
                                }
                            }
                        }
                    }
                    .frame(height: 100)
                }

                Spacer().frame(height: 10)

                // Player Area
                VStack(spacing: 8) {
                    HStack(spacing: 10) {
                        if playerHand.isEmpty {
                            cardPlaceholder
                        } else {
                            ForEach(playerHand) { card in
                                cardView(card: card)
                            }
                        }
                    }
                    .frame(height: 100)

                    Text("あなたの点数: \(Self.calculateScore(hand: playerHand))")
                        .font(.headline)
                        .foregroundColor(theme.textColor)
                }
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(red: 0.1, green: 0.35, blue: 0.2)) // Felt Green
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(theme.primaryColor.opacity(0.3), lineWidth: 3)
            )
            .padding(.horizontal)

            // Controls Block
            VStack(spacing: 12) {
                Text(statusMessage)
                    .font(.subheadline)
                    .foregroundColor(theme.textColor)
                    .multilineTextAlignment(.center)
                    .frame(height: 40)
                    .padding(.horizontal)

                if gameState == .betting {
                    // Betting layout
                    VStack(spacing: 10) {
                        Picker("ベット金額", selection: $betAmount) {
                            ForEach(betOptions, id: \.self) { opt in
                                Text("\(opt)チップ").tag(opt)
                            }
                        }
                        .pickerStyle(.segmented)

                        Button(action: startNewGame) {
                            Text("ディール (勝負開始)")
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background((stats?.chips ?? 0) < betAmount ? Color.gray : theme.gradient)
                                .cornerRadius(12)
                        }
                        .disabled((stats?.chips ?? 0) < betAmount)
                    }
                } else if gameState == .playerTurn {
                    // Turn layout
                    HStack(spacing: 10) {
                        Button(action: hit) {
                            Text("ヒット")
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(theme.gradient)
                                .cornerRadius(12)
                        }

                        Button(action: stand) {
                            Text("スタンド")
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .cornerRadius(12)
                        }

                        Button(action: doubleDown) {
                            Text("ダブル")
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background((stats?.chips ?? 0) < activeWager ? Color.gray : Color.orange)
                                .cornerRadius(12)
                        }
                        .disabled((stats?.chips ?? 0) < activeWager)
                    }
                } else {
                    // Game over reload button
                    Button(action: resetToBetting) {
                        Text("次のゲームへ")
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(theme.gradient)
                            .cornerRadius(12)
                    }
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 10)
        }
        .navigationTitle("ブラックジャック")
        .background(theme.backgroundColor)
    }

    // Card views rendering
    private var cardPlaceholder: some View {
        RoundedRectangle(cornerRadius: 8)
            .fill(Color.black.opacity(0.2))
            .frame(width: 70, height: 100)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.white.opacity(0.3), style: StrokeStyle(lineWidth: 1, dash: [4]))
            )
    }

    private var cardBack: some View {
        RoundedRectangle(cornerRadius: 8)
            .fill(LinearGradient(colors: [.red, .darkRed], startPoint: .topLeading, endPoint: .bottomTrailing))
            .frame(width: 70, height: 100)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.white, lineWidth: 2)
            )
            .shadow(radius: 2)
    }

    private func cardView(card: Card) -> some View {
        VStack {
            HStack {
                Text(card.displayValue)
                    .font(.headline)
                    .fontWeight(.bold)
                Spacer()
            }
            Spacer()
            Text(card.suit)
                .font(.title)
            Spacer()
            HStack {
                Spacer()
                Text(card.displayValue)
                    .font(.headline)
                    .fontWeight(.bold)
            }
        }
        .padding(6)
        .frame(width: 70, height: 100)
        .background(Color.white)
        .foregroundColor(card.isRed ? .red : .black)
        .cornerRadius(8)
        .shadow(radius: 2)
    }

    // Dealer scores display state
    private var dealerScoreDisplay: String {
        if dealerHand.isEmpty { return "0" }
        if gameState == .playerTurn {
            // Only count the visible first card
            return "\(Self.calculateScore(hand: Array(dealerHand.prefix(1))))"
        }
        return "\(Self.calculateScore(hand: dealerHand))"
    }

    // Game Actions
    private func generateDeck() -> [Card] {
        let suits = ["♠️", "♥️", "♦️", "♣️"]
        var tempDeck: [Card] = []
        for suit in suits {
            for val in 1...13 {
                tempDeck.append(Card(suit: suit, value: val))
            }
        }
        return tempDeck.shuffled()
    }

    static func calculateScore(hand: [Card]) -> Int {
        var score = 0
        var acesCount = 0

        for card in hand {
            if card.value == 1 {
                acesCount += 1
                score += 11
            } else if card.value >= 10 {
                score += 10
            } else {
                score += card.value
            }
        }

        while score > 21 && acesCount > 0 {
            score -= 10
            acesCount -= 1
        }

        return score
    }

    private func startNewGame() {
        guard let userStats = stats, userStats.chips >= betAmount else { return }

        // Deduct bet amount
        userStats.chips -= betAmount
        activeWager = betAmount

        // Setup deck and hands
        deck = generateDeck()
        playerHand = [deck.removeFirst(), deck.removeFirst()]
        dealerHand = [deck.removeFirst(), deck.removeFirst()]

        HapticService.shared.playHeavyImpact()
        gameState = .playerTurn
        statusMessage = "ヒットしてカードを引くか、スタンドして勝負します。"

        // Check for natural Blackjack
        let playerScore = Self.calculateScore(hand: playerHand)
        if playerScore == 21 {
            stand()
        }

        try? modelContext.save()
    }

    private func hit() {
        HapticService.shared.playLightImpact()
        playerHand.append(deck.removeFirst())

        let playerScore = Self.calculateScore(hand: playerHand)
        if playerScore > 21 {
            // Player Busts
            gameState = .gameOver
            statusMessage = "バスト！21を超えました。ディーラーの勝ちです。"
            payoutResult = "loss"
            HapticService.shared.playError()
        } else if playerScore == 21 {
            // Mandatory Stand
            stand()
        }
    }

    private func doubleDown() {
        guard let userStats = stats, userStats.chips >= activeWager else { return }

        // Deduct extra bet amount
        userStats.chips -= activeWager
        activeWager *= 2

        HapticService.shared.playHeavyImpact()
        // Draw exactly one card
        playerHand.append(deck.removeFirst())

        let playerScore = Self.calculateScore(hand: playerHand)
        if playerScore > 21 {
            gameState = .gameOver
            statusMessage = "バスト！21を超えました。ディーラーの勝ちです。"
            payoutResult = "loss"
            HapticService.shared.playError()
        } else {
            stand()
        }

        try? modelContext.save()
    }

    private func stand() {
        gameState = .dealerTurn
        statusMessage = "ディーラーのターンです..."

        // Dealer plays
        var dealerScore = Self.calculateScore(hand: dealerHand)
        let playerScore = Self.calculateScore(hand: playerHand)

        // Run dealer hit logic with small delay (simulated loop)
        while dealerScore < 17 {
            dealerHand.append(deck.removeFirst())
            dealerScore = Self.calculateScore(hand: dealerHand)
        }

        evaluateOutcome()
    }

    private func evaluateOutcome() {
        guard let userStats = stats else { return }

        let playerScore = Self.calculateScore(hand: playerHand)
        let dealerScore = Self.calculateScore(hand: dealerHand)

        gameState = .gameOver

        if playerScore > 21 {
            statusMessage = "あなたのバスト！ディーラーの勝ちです。"
            payoutResult = "loss"
            HapticService.shared.playError()
        } else if dealerScore > 21 {
            // Dealer busts, player wins
            let payout = Int(Double(activeWager) * 2)
            userStats.chips += payout
            statusMessage = "ディーラーがバストしました！あなたの勝ちです！\n💰 \(payout)チップを獲得！"
            payoutResult = "win"
            HapticService.shared.playSuccess()
        } else if playerScore == dealerScore {
            // Push
            userStats.chips += activeWager
            statusMessage = "引き分け（プッシュ）です。\n💰 \(activeWager)チップが返却されました。"
            payoutResult = "push"
            HapticService.shared.playMediumImpact()
        } else if playerScore == 21 && playerHand.count == 2 {
            // Blackjack natural pay 2.5x
            let payout = Int(Double(activeWager) * 2.5)
            userStats.chips += payout
            statusMessage = "ブラックジャック！あなたの勝ちです！\n💰 \(payout)チップを獲得！"
            payoutResult = "blackjack"
            HapticService.shared.playSuccess()
        } else if playerScore > dealerScore {
            // Win
            let payout = Int(Double(activeWager) * 2)
            userStats.chips += payout
            statusMessage = "あなたの勝ちです！\(playerScore) vs \(dealerScore)\n💰 \(payout)チップを獲得！"
            payoutResult = "win"
            HapticService.shared.playSuccess()
        } else {
            // Loss
            statusMessage = "ディーラーの勝ちです。\(playerScore) vs \(dealerScore)"
            payoutResult = "loss"
            HapticService.shared.playWarning()
        }

        try? modelContext.save()
    }

    private func resetToBetting() {
        HapticService.shared.playSelection()
        playerHand = []
        dealerHand = []
        activeWager = 0
        gameState = .betting
        statusMessage = "ベット額を選んでカードを配ってください！"
    }
}

extension Color {
    static let darkRed = Color(red: 0.6, green: 0.0, blue: 0.0)
}
