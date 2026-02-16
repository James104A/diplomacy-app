import SwiftUI

@main
struct DiplomacyApp: App {
    @StateObject private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            Group {
                if appState.isAuthenticated {
                    AppTabView()
                        .onOpenURL { url in
                            DeepLinkRouter.handle(url: url, appState: appState)
                        }
                } else {
                    WelcomeView()
                }
            }
            .environmentObject(appState)
            .task {
                // Check for existing tokens on launch
                let hasTokens = await AuthService.shared.hasStoredTokens()
                if hasTokens {
                    appState.isAuthenticated = true
                }
            }
        }
    }
}
