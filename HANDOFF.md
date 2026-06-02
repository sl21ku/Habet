# Habet Handoff

Last updated: 2026-06-02

## Current Status

Repository:
```text
https://github.com/sl21ku/Habet
```

Local workspace:
```text
H:\slot
```

CI Setup:
- `xcodegen generate`
- iOS Simulator build
- Unit tests
- UI tests

The working tree will be clean after commit and push.

## What Was Done Today

Built the initial native iOS MVP codebase for **Habet (ハビット・ベット)**.

Implemented:
- **SwiftUI App Shell & Custom Theme Engine**:
  - Configured environment keys and modifiers (`ThemeModifier.swift`) supporting Default, Gold VIP, Cyberpunk Neon, and OLED Dark themes. Changing themes affects all screens instantly.
- **SwiftData Models**:
  - `HabitBetModel.swift` for saving ongoing and completed bets.
  - `UserStatsModel.swift` for saving chip balances, stats, and unlocked customizations.
- **Haptic Feedback Service**:
  - `HapticService.swift` using UIKit `UIImpactFeedbackGenerator` and others, delivering tactile ticks, win rumbles, and loss buzzes.
- **Lock Screen Widgets & Live Activities Extension**:
  - Shared `HabetWidgetAttributes.swift` for ActivityKit configuration.
  - `ActivityService.swift` controlling request, update, and end actions.
  - `HabetWidget.swift` rendering standard rectangular & small widgets reading user stats from App Groups shared context.
  - `HabetWidgetLiveActivity.swift` rendering timer clocks, wager values, and Dynamic Island nodes.
- **Lobby & Form Configurator**:
  - `HomeView.swift` showing stats and bet histories.
  - `ActiveBetCard.swift` with live tickers and photo-proofing sheet.
  - `BetSetupView.swift` with quick presets (including a 1-minute test bet), chip verification, and slider picker.
- **Casino Games**:
  - `SlotMachineView.swift` with emoji reels, delayed spins, and auto-unlocking of Gold theme & Crown avatar on Jackpots.
  - `BlackjackView.swift` with full deck mechanics, hits, stands, doubles, and Ace conversions.
- **Customization Shop & Stats**:
  - `ShopView.swift` supporting theme and avatar purchases.
  - `ProfileView.swift` with stat metrics, chip refilling, and database resets.
- **GitHub Actions iOS CI Configuration**:
  - Configured `ios-ci.yml` runner on `macos-15` running XcodeGen, selecting simulators, compiling target schemes, and executing tests.
- **Unit and UI Test Suites**:
  - `HabetTests.swift` testing model creation and Blackjack score math.
  - `HabetUITests.swift` testing page launches and presets click configurations.

## Current App Structure

```text
Habet/
  App/
    HabetApp.swift
    AppModelContainer.swift
    RootView.swift
  Models/
    HabitBetModel.swift
    UserStatsModel.swift
    HabetWidgetAttributes.swift
  Services/
    HapticService.swift
    ActivityService.swift
    DemoDataService.swift
  Features/
    Home/
      HomeView.swift
      ActiveBetCard.swift
    BetSetup/
      BetSetupView.swift
    Casino/
      CasinoView.swift
      SlotMachineView.swift
      BlackjackView.swift
    Shop/
      ShopView.swift
      ThemeModifier.swift
    Profile/
      ProfileView.swift
  Support/
    Info.plist
    Habet.entitlements
    PrivacyInfo.xcprivacy

HabetWidgetExtension/
  Info.plist
  HabetWidgetExtension.entitlements
  HabetWidget.swift
  HabetWidgetLiveActivity.swift

Tests/
  HabetTests/
    HabetTests.swift
  HabetUITests/
    HabetUITests.swift
```

## Setup & Verification Next Steps

1. **Verify code generation & local builds on macOS**:
   If checking out on macOS, run:
   ```sh
   xcodegen generate
   open Habet.xcodeproj
   ```
2. **Review configurations**:
   Check signing team and bundle prefix. The current configuration is defaulted to `com.sl21ku` and App Group `group.com.sl21ku.Habet`.
3. **Run tests in GitHub Actions**:
   When changes are pushed, the `.github/workflows/ios-ci.yml` will trigger and run full simulator builds and test cases.
