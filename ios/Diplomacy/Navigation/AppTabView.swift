import SwiftUI

enum AppTab: String, CaseIterable {
    case games
    case social
    case learn
    case profile

    var title: String {
        switch self {
        case .games: return "Games"
        case .social: return "Social"
        case .learn: return "Learn"
        case .profile: return "Profile"
        }
    }

    var iconName: String {
        switch self {
        case .games: return "swords"
        case .social: return "person.2"
        case .learn: return "graduationcap"
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

            SocialTab()
                .tabItem {
                    Label(AppTab.social.title, systemImage: AppTab.social.iconName)
                }
                .tag(AppTab.social)
                .badge(appState.pendingFriendRequests)

            LearnTab()
                .tabItem {
                    Label(AppTab.learn.title, systemImage: AppTab.learn.iconName)
                }
                .tag(AppTab.learn)

            ProfileTab()
                .tabItem {
                    Label(AppTab.profile.title, systemImage: AppTab.profile.iconName)
                }
                .tag(AppTab.profile)
        }
        .onChange(of: appState.deepLinkTab) { newTab in
            if let tab = newTab {
                selectedTab = tab
                appState.deepLinkTab = nil
            }
        }
    }
}
