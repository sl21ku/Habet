import SwiftData
import SwiftUI

@main
struct HabetApp: App {
    private let modelContainer = AppModelContainer.make()

    var body: some Scene {
        WindowGroup {
            RootView()
        }
        .modelContainer(modelContainer)
    }
}
