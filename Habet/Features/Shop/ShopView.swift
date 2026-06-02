import SwiftData
import SwiftUI

struct ShopView: View {
    @Query private var statsList: [UserStatsModel]
    @Environment(\.modelContext) private var modelContext
    @Environment(\.appTheme) private var theme

    private var stats: UserStatsModel? {
        statsList.first
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Header card showing current chips
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("現在の所持チップ")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            HStack(spacing: 4) {
                                Text("💰")
                                    .font(.title2)
                                Text("\(stats?.chips ?? 0)")
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .foregroundColor(theme.textColor)
                            }
                        }
                        Spacer()
                    }
                    .padding()
                    .background(theme.cardColor)
                    .cornerRadius(16)
                    .padding(.horizontal)

                    // Theme Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("カラーテーマ")
                            .font(.headline)
                            .foregroundColor(theme.textColor)
                            .padding(.horizontal)

                        ForEach(AppTheme.allCases) { item in
                            themeShopItemRow(for: item)
                        }
                        .padding(.horizontal)
                    }

                    // Avatar Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("アバター・称号")
                            .font(.headline)
                            .foregroundColor(theme.textColor)
                            .padding(.horizontal)

                        ForEach(AvatarItem.allCases) { item in
                            avatarShopItemRow(for: item)
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("ショップ")
            .background(theme.backgroundColor)
        }
    }

    // Custom row styling for visual themes
    private func themeShopItemRow(for item: AppTheme) -> some View {
        let isUnlocked = stats?.unlockedThemeIds.contains(item.rawValue) ?? false
        let isActive = stats?.activeThemeId == item.rawValue

        return HStack(spacing: 16) {
            // Theme Preview circle
            Circle()
                .fill(item.gradient)
                .frame(width: 44, height: 44)

            VStack(alignment: .leading, spacing: 4) {
                Text(item.displayName)
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(theme.textColor)

                Text(item.description)
                    .font(.system(size: 10))
                    .foregroundColor(.secondary)
            }

            Spacer()

            if isActive {
                Text("適用中")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(theme.primaryColor)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(theme.primaryColor.opacity(0.1))
                    .cornerRadius(8)
            } else if isUnlocked {
                Button(action: { selectTheme(item) }) {
                    Text("選択")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.gray)
                        .cornerRadius(8)
                }
            } else {
                Button(action: { buyTheme(item) }) {
                    HStack(spacing: 2) {
                        Text("💰")
                        Text("\(item.price)")
                    }
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background((stats?.chips ?? 0) >= item.price ? theme.gradient : LinearGradient(colors: [.gray], startPoint: .top, endPoint: .bottom))
                    .cornerRadius(8)
                }
                .disabled((stats?.chips ?? 0) < item.price)
            }
        }
        .padding()
        .background(theme.cardColor)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isActive ? theme.primaryColor : Color.clear, lineWidth: 1)
        )
    }

    // Custom row styling for avatars
    private func avatarShopItemRow(for item: AvatarItem) -> some View {
        let isUnlocked = stats?.unlockedAvatarIds.contains(item.rawValue) ?? false
        let isActive = stats?.activeAvatarId == item.rawValue

        return HStack(spacing: 16) {
            // Avatar Emoji display
            Text(item.emoji)
                .font(.system(size: 32))
                .frame(width: 44, height: 44)
                .background(theme.backgroundColor)
                .cornerRadius(22)

            VStack(alignment: .leading, spacing: 4) {
                Text(item.displayName)
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(theme.textColor)

                Text(item.description)
                    .font(.system(size: 10))
                    .foregroundColor(.secondary)
            }

            Spacer()

            if isActive {
                Text("適用中")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(theme.primaryColor)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(theme.primaryColor.opacity(0.1))
                    .cornerRadius(8)
            } else if isUnlocked {
                Button(action: { selectAvatar(item) }) {
                    Text("選択")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.gray)
                        .cornerRadius(8)
                }
            } else {
                Button(action: { buyAvatar(item) }) {
                    HStack(spacing: 2) {
                        Text("💰")
                        Text("\(item.price)")
                    }
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background((stats?.chips ?? 0) >= item.price ? theme.gradient : LinearGradient(colors: [.gray], startPoint: .top, endPoint: .bottom))
                    .cornerRadius(8)
                }
                .disabled((stats?.chips ?? 0) < item.price)
            }
        }
        .padding()
        .background(theme.cardColor)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isActive ? theme.primaryColor : Color.clear, lineWidth: 1)
        )
    }

    // Actions
    private func selectTheme(_ item: AppTheme) {
        guard let userStats = stats else { return }
        HapticService.shared.playSelection()
        userStats.activeThemeId = item.rawValue
        try? modelContext.save()
    }

    private func buyTheme(_ item: AppTheme) {
        guard let userStats = stats, userStats.chips >= item.price else { return }
        HapticService.shared.playSuccess()
        userStats.chips -= item.price
        userStats.unlockedThemeIds.append(item.rawValue)
        userStats.activeThemeId = item.rawValue
        try? modelContext.save()
    }

    private func selectAvatar(_ item: AvatarItem) {
        guard let userStats = stats else { return }
        HapticService.shared.playSelection()
        userStats.activeAvatarId = item.rawValue
        try? modelContext.save()
    }

    private func buyAvatar(_ item: AvatarItem) {
        guard let userStats = stats, userStats.chips >= item.price else { return }
        HapticService.shared.playSuccess()
        userStats.chips -= item.price
        userStats.unlockedAvatarIds.append(item.rawValue)
        userStats.activeAvatarId = item.rawValue
        try? modelContext.save()
    }
}

// Avatar items enum
enum AvatarItem: String, CaseIterable, Identifiable {
    case `default` = "default"
    case crown = "crown"
    case glasses = "glasses"
    case cat = "cat"

    var id: String { self.rawValue }

    var displayName: String {
        switch self {
        case .default: return "ビギナー"
        case .crown: return "ロイヤルチャレンジャー"
        case .glasses: return "ハイローラー"
        case .cat: return "ラッキーキャット"
        }
    }

    var emoji: String {
        switch self {
        case .default: return "👤"
        case .crown: return "👑"
        case .glasses: return "😎"
        case .cat: return "🐱"
        }
    }

    var description: String {
        switch self {
        case .default: return "標準のアバター（無料）"
        case .crown: return "富と権威を象徴する王冠（スロットのジャックポットでも入手可能）"
        case .glasses: return "大胆に賭けを好む者のクールなサングラス"
        case .cat: return "チップの稼ぎを招く幸福の招き猫"
        }
    }

    var price: Int {
        switch self {
        case .default: return 0
        case .crown: return 1000
        case .glasses: return 1500
        case .cat: return 2500
        }
    }
}
