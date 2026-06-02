import SwiftUI

enum AppTheme: String, CaseIterable, Identifiable {
    case `default` = "default"
    case gold = "gold"
    case neon = "neon"
    case oled = "oled"

    var id: String { self.rawValue }

    var displayName: String {
        switch self {
        case .default: return "デフォルト"
        case .gold: return "ゴールド VIP"
        case .neon: return "サイバーネオン"
        case .oled: return "OLED ダーク"
        }
    }

    var description: String {
        switch self {
        case .default: return "標準のクリーンなデザイン"
        case .gold: return "VIP感漂うラグジュアリーな金と黒"
        case .neon: return "ネオンが輝く近未来サイバーパンク"
        case .oled: return "バッテリーに優しい究極の漆黒"
        }
    }

    var price: Int {
        switch self {
        case .default: return 0
        case .gold: return 1000
        case .neon: return 500
        case .oled: return 300
        }
    }

    var primaryColor: Color {
        switch self {
        case .default: return Color.blue
        case .gold: return Color(red: 0.85, green: 0.65, blue: 0.13) // Gold metallic
        case .neon: return Color.pink
        case .oled: return Color.white
        }
    }

    var accentColor: Color {
        switch self {
        case .default: return Color.cyan
        case .gold: return Color(red: 1.0, green: 0.84, blue: 0.0) // Bright Gold
        case .neon: return Color.green
        case .oled: return Color(white: 0.6)
        }
    }

    var backgroundColor: Color {
        switch self {
        case .default: return Color(uiColor: .systemBackground)
        case .gold: return Color(red: 0.05, green: 0.05, blue: 0.05)
        case .neon: return Color(red: 0.08, green: 0.02, blue: 0.15)
        case .oled: return Color.black
        }
    }

    var cardColor: Color {
        switch self {
        case .default: return Color(uiColor: .secondarySystemBackground)
        case .gold: return Color(red: 0.12, green: 0.12, blue: 0.12)
        case .neon: return Color(red: 0.16, green: 0.05, blue: 0.28)
        case .oled: return Color(white: 0.08)
        }
    }

    var textColor: Color {
        switch self {
        case .default: return .primary
        case .gold: return Color(red: 0.95, green: 0.9, blue: 0.8)
        case .neon: return Color(red: 0.9, green: 0.9, blue: 1.0)
        case .oled: return .white
        }
    }

    var gradient: LinearGradient {
        switch self {
        case .default:
            return LinearGradient(colors: [.blue, .cyan], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .gold:
            return LinearGradient(colors: [Color(red: 0.72, green: 0.53, blue: 0.04), Color(red: 1.0, green: 0.84, blue: 0.0)], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .neon:
            return LinearGradient(colors: [.pink, .purple], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .oled:
            return LinearGradient(colors: [.gray, .black], startPoint: .topLeading, endPoint: .bottomTrailing)
        }
    }
}

struct AppThemeKey: EnvironmentKey {
    static let defaultValue: AppTheme = .default
}

extension EnvironmentValues {
    var appTheme: AppTheme {
        get { self[AppThemeKey.self] }
        set { self[AppThemeKey.self] = newValue }
    }
}

struct ThemeViewModifier: ViewModifier {
    let theme: AppTheme

    func body(content: Content) -> some View {
        content
            .environment(\.appTheme, theme)
            .preferredColorScheme(theme == .default ? nil : .dark)
            .background(theme.backgroundColor.ignoresSafeArea())
    }
}

extension View {
    func appTheme(_ theme: AppTheme) -> some View {
        self.modifier(ThemeViewModifier(theme: theme))
    }
}
