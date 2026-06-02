import SwiftData
import SwiftUI

struct RootView: View {
    @Query private var statsList: [UserStatsModel]
    @State private var selectedTab = 0

    private var currentTheme: AppTheme {
        guard let stats = statsList.first else { return .default }
        return AppTheme(rawValue: stats.activeThemeId) ?? .default
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView(selectedTab: $selectedTab)
                .tag(0)
                .tabItem {
                    Label("ホーム", systemImage: "house.fill")
                }

            BetSetupView(selectedTab: $selectedTab)
                .tag(1)
                .tabItem {
                    Label("ベット", systemImage: "arrow.up.forward.circle.fill")
                }

            CasinoView()
                .tag(2)
                .tabItem {
                    Label("カジノ", systemImage: "dice.fill")
                }

            ShopView()
                .tag(3)
                .tabItem {
                    Label("ショップ", systemImage: "bag.fill")
                }

            ProfileView()
                .tag(4)
                .tabItem {
                    Label("プロフ", systemImage: "person.fill")
                }
        }
        .appTheme(currentTheme)
        .tint(currentTheme.primaryColor)
    }
}
