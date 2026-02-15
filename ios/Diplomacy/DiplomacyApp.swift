import SwiftUI

@main
struct DiplomacyApp: App {
    @StateObject private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            AppTabView()
                .environmentObject(appState)
                .onOpenURL { url in
                    DeepLinkRouter.handle(url: url, appState: appState)
                }
        }
    }
}
