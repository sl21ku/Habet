import SwiftData
import SwiftUI

@main
struct HabetApp: App {
    private let modelContainer = AppModelContainer.make()

    var body: some Scene {
        WindowGroup {
            RootView()
                .onAppear {
                    DemoDataService.seedIfNeeded(modelContext: modelContainer.mainContext)
                }
        }
        .modelContainer(modelContainer)
    }
}
