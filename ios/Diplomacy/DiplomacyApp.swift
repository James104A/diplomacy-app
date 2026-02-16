import SwiftUI

@main
struct DiplomacyApp: App {
    @StateObject private var appState = AppState()
    @State private var showJoinSheet = false
    @State private var pendingInviteCode: String?

    var body: some Scene {
        WindowGroup {
            Group {
                if appState.isAuthenticated {
                    AppTabView()
                        .onOpenURL { url in
                            DeepLinkRouter.handle(url: url, appState: appState)
                        }
                        .sheet(isPresented: $showJoinSheet) {
                            if let code = pendingInviteCode {
                                JoinGameSheet(inviteCode: code)
                                    .environmentObject(appState)
                            }
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
            .onChange(of: appState.isAuthenticated) { isAuth in
                if isAuth {
                    WebSocketManager.shared.connect()
                } else {
                    WebSocketManager.shared.disconnect()
                }
            }
            .onChange(of: appState.deepLinkInviteCode) { code in
                if let code {
                    pendingInviteCode = code
                    showJoinSheet = true
                    appState.deepLinkInviteCode = nil
                }
            }
        }
    }
}
