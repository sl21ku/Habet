import SwiftData
import SwiftUI
import PhotosUI
import UIKit

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
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var selectedImageData: Data? = nil
    @State private var selectedImage: UIImage? = nil
    @State private var isAnalyzing = false
    @State private var analysisSuccessMessage: String? = nil
    @State private var analysisErrorMessage: String? = nil
    @State private var noteText = ""

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("「\(habitName)」の達成証明")
                    .font(.headline)
                    .padding(.top)

                Text("Apple Vision AI が証拠写真を解析し、習慣の達成を自動判定します。")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                VStack {
                    if let image = selectedImage {
                        ZStack {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFit()
                                .frame(height: 180)
                                .cornerRadius(12)
                                .shadow(radius: 3)

                            if isAnalyzing {
                                ZStack {
                                    Color.black.opacity(0.6)
                                        .cornerRadius(12)
                                    VStack(spacing: 8) {
                                        ProgressView()
                                            .tint(.white)
                                        Text("AI 解析中...")
                                            .font(.caption)
                                            .foregroundColor(.white)
                                            .fontWeight(.bold)
                                    }
                                }
                                .frame(height: 180)
                            }
                        }
                    } else {
                        // Empty State Placeholder
                        VStack(spacing: 12) {
                            Image(systemName: "photo.badge.plus")
                                .font(.system(size: 44))
                                .foregroundColor(theme.primaryColor)
                            Text("アルバムから証拠写真を選択")
                                .font(.subheadline)
                                .fontWeight(.bold)
                            Text("読書・勉強は「文字の写った写真」\n筋トレ・ランは「運動器具・スニーカー」")
                                .font(.system(size: 10))
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 180)
                        .background(theme.cardColor)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.secondary.opacity(0.3), style: StrokeStyle(lineWidth: 1, dash: [5]))
                        )
                    }
                }
                .padding(.horizontal)

                // Pick/Change Photo Button
                PhotosPicker(selection: $selectedItem, matching: .images) {
                    Label(selectedImage == nil ? "写真を選択する" : "写真を変更する", systemImage: "photo")
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(theme.gradient)
                        .cornerRadius(10)
                }
                .padding(.horizontal)
                .disabled(isAnalyzing)

                // AI Verification Output Banner
                Group {
                    if let successMsg = analysisSuccessMessage {
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Image(systemName: "checkmark.seal.fill")
                                    .foregroundColor(.green)
                                Text("AI判定: 合格！")
                                    .fontWeight(.bold)
                                    .foregroundColor(.green)
                            }
                            Text(successMsg)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.green.opacity(0.1))
                        .cornerRadius(10)
                        .padding(.horizontal)
                    } else if let errorMsg = analysisErrorMessage {
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Image(systemName: "xmark.octagon.fill")
                                    .foregroundColor(.red)
                                Text("AI判定: 不合格")
                                    .fontWeight(.bold)
                                    .foregroundColor(.red)
                            }
                            Text(errorMsg)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(10)
                        .padding(.horizontal)
                    }
                }

                TextField("達成のひと言メモ（任意）", text: $noteText)
                    .textFieldStyle(.roundedBorder)
                    .padding(.horizontal)
                    .disabled(isAnalyzing)

                Spacer()

                // Submit Button
                VStack(spacing: 8) {
                    Button(action: {
                        HapticService.shared.playSuccess()
                        onVerify(selectedImageData)
                        dismiss()
                    }) {
                        Text("証明を送信して精算する")
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(
                                analysisSuccessMessage != nil
                                ? theme.gradient
                                : LinearGradient(colors: [.gray], startPoint: .top, endPoint: .bottom)
                            )
                            .cornerRadius(12)
                    }
                    .disabled(analysisSuccessMessage == nil || isAnalyzing)

                    // Debug/Simulator bypass button
                    Button(action: {
                        HapticService.shared.playSuccess()
                        analysisSuccessMessage = "開発者用パス: テスト判定をパスしました。"
                        onVerify(Data())
                        dismiss()
                    }) {
                        Text("シミュレータ用モック合格 (開発テスト)")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    .padding(.bottom, 10)
                }
                .padding(.horizontal)
            }
            .navigationTitle("AI完了証明")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("キャンセル") {
                        dismiss()
                    }
                }
            }
            .onChange(of: selectedItem) { _, newItem in
                Task {
                    guard let item = newItem else { return }
                    isAnalyzing = true
                    analysisSuccessMessage = nil
                    analysisErrorMessage = nil

                    if let data = try? await item.loadTransferable(type: Data.self) {
                        await MainActor.run {
                            self.selectedImageData = data
                            self.selectedImage = UIImage(data: data)
                        }

                        // Run Vision AI Image classification in background
                        AIImageVerificationService.verifyImage(imageData: data, category: habitName) { success, message in
                            Task { @MainActor in
                                self.isAnalyzing = false
                                if success {
                                    self.analysisSuccessMessage = message
                                    HapticService.shared.playSuccess()
                                } else {
                                    self.analysisErrorMessage = message
                                    HapticService.shared.playWarning()
                                }
                            }
                        }
                    } else {
                        await MainActor.run {
                            self.isAnalyzing = false
                            self.analysisErrorMessage = "画像の読み込みに失敗しました。"
                        }
                    }
                }
            }
        }
    }
}
