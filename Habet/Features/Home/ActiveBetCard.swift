import SwiftData
import SwiftUI

struct ActiveBetCard: View {
    let bet: HabitBetModel
    let stats: UserStatsModel

    @Environment(\.modelContext) private var modelContext
    @Environment(\.appTheme) private var theme

    @State private var timeRemaining: TimeInterval = 0
    @State private var timerActive = true
    @State private var showPhotoPicker = false

    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("挑戦中のベット")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(theme.accentColor)

                    Text(bet.habitName)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(theme.textColor)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    Text("賭け金")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    HStack(spacing: 2) {
                        Text("💰")
                        Text("\(bet.betAmount)")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(theme.textColor)
                    }
                }
            }

            Divider()

            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("オッズ: \(String(format: "%.1fx", bet.odds))")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(theme.textColor)

                    Text("獲得予定: 💰 \(Int(Double(bet.betAmount) * bet.odds))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                VStack(alignment: .trailing) {
                    Text("残り時間")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Text(timeString(from: timeRemaining))
                        .font(.title3)
                        .fontDesign(.monospaced)
                        .fontWeight(.bold)
                        .foregroundColor(timeRemaining < 60 ? .red : theme.textColor)
                }
            }

            HStack(spacing: 12) {
                // Forfeit Button
                Button(action: forfeitBet) {
                    Text("諦める")
                        .fontWeight(.medium)
                        .foregroundColor(.red)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(10)
                }

                // Complete Button
                Button(action: {
                    HapticService.shared.playSelection()
                    showPhotoPicker = true
                }) {
                    Text("完了を証明する")
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(theme.gradient)
                        .cornerRadius(10)
                }
            }
        }
        .padding()
        .background(theme.cardColor)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(theme.primaryColor.opacity(0.3), lineWidth: 1)
        )
        .onAppear {
            updateTimeRemaining()
        }
        .onReceive(timer) { _ in
            if timerActive {
                updateTimeRemaining()
            }
        }
        .sheet(isPresented: $showPhotoPicker) {
            PhotoProofView(habitName: bet.habitName) { imageData in
                completeBet(imageData: imageData)
            }
        }
    }

    private func updateTimeRemaining() {
        let remaining = bet.endDate.timeIntervalSince(Date())
        if remaining <= 0 {
            timeRemaining = 0
            timerActive = false
            failBet()
        } else {
            timeRemaining = remaining
        }
    }

    private func timeString(from interval: TimeInterval) -> String {
        let hours = Int(interval) / 3600
        let minutes = (Int(interval) % 3600) / 60
        let seconds = Int(interval) % 60

        if hours > 0 {
            return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%02d:%02d", minutes, seconds)
        }
    }

    private func completeBet(imageData: Data?) {
        bet.isCompleted = true
        bet.isSuccessful = true
        bet.completionPhotoData = imageData

        let payout = Int(Double(bet.betAmount) * bet.odds)
        stats.chips += payout
        stats.wonBetsCount += 1
        stats.totalBetsCount += 1

        ActivityService.shared.endLiveActivity()
        HapticService.shared.playSuccess()

        try? modelContext.save()
    }

    private func forfeitBet() {
        bet.isCompleted = true
        bet.isSuccessful = false
        stats.totalBetsCount += 1

        ActivityService.shared.endLiveActivity()
        HapticService.shared.playWarning()

        try? modelContext.save()
    }

    private func failBet() {
        bet.isCompleted = true
        bet.isSuccessful = false
        stats.totalBetsCount += 1

        ActivityService.shared.endLiveActivity()
        HapticService.shared.playError()

        try? modelContext.save()
    }
}

struct PhotoProofView: View {
    let habitName: String
    let onVerify: (Data?) -> Void

    @Environment(\.dismiss) private var dismiss
    @Environment(\.appTheme) private var theme
    @State private var isCameraSimulated = false
    @State private var selectedProofIndex: Int?
    @State private var noteText = ""

    // Hardcoded patterns that simulate physical verification photo options in SwiftUI
    private let mockProofImages = [
        "book.closed.fill",
        "dumbbell.fill",
        "doc.text.fill",
        "figure.run",
        "cup.and.saucer.fill"
    ]

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("「\(habitName)」の達成証明")
                    .font(.headline)
                    .padding(.top)

                Text("達成を証明する証拠写真を選択または撮影してください。")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                if isCameraSimulated {
                    VStack {
                        ZStack {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.black)
                                .frame(height: 180)

                            VStack(spacing: 12) {
                                Image(systemName: selectedProofIndex != nil ? mockProofImages[selectedProofIndex!] : "camera.fill")
                                    .font(.system(size: 40))
                                    .foregroundColor(theme.primaryColor)

                                Text("カメラによる撮影完了！")
                                    .font(.caption)
                                    .foregroundColor(.white)
                            }
                        }

                        Button(action: {
                            HapticService.shared.playSelection()
                            isCameraSimulated = false
                            selectedProofIndex = nil
                        }) {
                            Text("撮り直す")
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                    }
                    .padding(.horizontal)
                } else {
                    VStack(spacing: 12) {
                        Text("証拠カテゴリを選択")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal)

                        HStack(spacing: 12) {
                            ForEach(0..<mockProofImages.count, id: \.self) { index in
                                Button(action: {
                                    HapticService.shared.playSelection()
                                    selectedProofIndex = index
                                    isCameraSimulated = true
                                }) {
                                    VStack {
                                        Image(systemName: mockProofImages[index])
                                            .font(.title2)
                                        Text(categoryName(for: index))
                                            .font(.system(size: 8))
                                    }
                                    .frame(width: 55, height: 55)
                                    .background(theme.cardColor)
                                    .cornerRadius(10)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(selectedProofIndex == index ? theme.primaryColor : Color.clear, lineWidth: 2)
                                    )
                                }
                            }
                        }
                        .padding(.horizontal)

                        Button(action: {
                            HapticService.shared.playSelection()
                            isCameraSimulated = true
                            selectedProofIndex = 0 // default to studying book
                        }) {
                            Label("カメラで即座に撮影", systemImage: "camera")
                                .font(.subheadline)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(theme.gradient)
                                .cornerRadius(10)
                                .padding(.horizontal)
                        }
                    }
                }

                TextField("達成のひと言メモ（任意）", text: $noteText)
                    .textFieldStyle(.roundedBorder)
                    .padding(.horizontal)

                Spacer()

                Button(action: {
                    HapticService.shared.playSuccess()
                    // Pass empty data for simulator proofing success
                    onVerify(Data())
                    dismiss()
                }) {
                    Text("証明を送信して精算する")
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(isCameraSimulated ? theme.gradient : LinearGradient(colors: [.gray], startPoint: .top, endPoint: .bottom))
                        .cornerRadius(12)
                        .padding(.horizontal)
                        .padding(.bottom, 20)
                }
                .disabled(!isCameraSimulated)
            }
            .navigationTitle("完了証明")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("キャンセル") {
                        dismiss()
                    }
                }
            }
        }
    }

    private func categoryName(for index: Int) -> String {
        switch index {
        case 0: return "勉強"
        case 1: return "筋トレ"
        case 2: return "作業"
        case 3: return "ラン"
        case 4: return "その他"
        default: return ""
        }
    }
}
