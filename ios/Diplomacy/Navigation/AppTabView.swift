import SwiftUI

enum AppTab: String, CaseIterable {
    case games
    case profile

    var title: String {
        switch self {
        case .games: return "Games"
        case .profile: return "Profile"
        }
    }

    var iconName: String {
        switch self {
        case .games: return "flag.fill"
        case .profile: return "person.circle"
        }
    }
}

struct AppTabView: View {
    @EnvironmentObject var appState: AppState
    @State private var selectedTab: AppTab = .games

    var body: some View {
        TabView(selection: $selectedTab) {
            GamesTab()
                .tabItem {
                    Label(AppTab.games.title, systemImage: AppTab.games.iconName)
                }
                .tag(AppTab.games)
                .badge(appState.gamesNeedingAttention)

            ProfileTab()
                .tabItem {
                    Label(AppTab.profile.title, systemImage: AppTab.profile.iconName)
                }
                .tag(AppTab.profile)
                .badge(appState.pendingFriendRequests)
        }
        .onChange(of: appState.deepLinkTab) { newTab in
            if let tab = newTab {
                selectedTab = tab
                appState.deepLinkTab = nil
            }
        }
    }
}
