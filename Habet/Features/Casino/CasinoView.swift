import SwiftData
import SwiftUI

struct CasinoView: View {
    @Query private var statsList: [UserStatsModel]
    @Environment(\.appTheme) private var theme

    private var stats: UserStatsModel? {
        statsList.first
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                // Lobby banner with chip counts
                VStack(spacing: 8) {
                    Text("カジノ・ロビー")
                        .font(.headline)
                        .foregroundColor(.secondary)

                    HStack(spacing: 8) {
                        Text("💰")
                            .font(.system(size: 32))
                        Text("\(stats?.chips ?? 0)")
                            .font(.system(size: 40, weight: .black, design: .rounded))
                            .foregroundColor(theme.textColor)
                    }
                    Text("貯まったチップでスロットやカードをプレイ！")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(theme.cardColor)
                .cornerRadius(20)
                .shadow(color: theme.primaryColor.opacity(0.1), radius: 10, x: 0, y: 5)
                .padding(.horizontal)

                // Menu items
                VStack(spacing: 16) {
                    NavigationLink(destination: SlotMachineView()) {
                        lobbyCard(
                            title: "ラッキースロット",
                            description: "3つのリールを揃えてジャックポット！\n揃えば最大100倍。1回 10チップ〜",
                            icon: "🎰",
                            accentColor: .orange
                        )
                    }
                    .buttonStyle(.plain)

                    NavigationLink(destination: BlackjackView()) {
                        lobbyCard(
                            title: "ブラックジャック",
                            description: "ディーラーとの心理対決！\n合計値を21に近づけて賭けチップを倍に。",
                            icon: "🃏",
                            accentColor: .red
                        )
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal)

                Spacer()
            }
            .padding(.vertical)
            .navigationTitle("カジノ")
            .background(theme.backgroundColor)
        }
    }

    private func lobbyCard(title: String, description: String, icon: String, accentColor: Color) -> some View {
        HStack(spacing: 16) {
            Text(icon)
                .font(.system(size: 50))
                .padding()
                .background(accentColor.opacity(0.15))
                .cornerRadius(16)

            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(theme.textColor)

                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.headline)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(theme.cardColor)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.secondary.opacity(0.1), lineWidth: 1)
        )
    }
}
