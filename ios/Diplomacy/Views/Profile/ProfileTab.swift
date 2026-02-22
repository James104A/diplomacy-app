import SwiftUI

struct ProfileTab: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        NavigationStack {
            List {
                Section("Profile") {
                    NavigationLink {
                        Text("Coming soon")
                    } label: {
                        Label {
                            VStack(alignment: .leading, spacing: Spacing.xxs) {
                                Text("Stats & Settings")
                                    .font(.appTitle)
                                Text("Stats, settings, and achievements")
                                    .font(.appCaption)
                                    .foregroundColor(.appSecondary)
                            }
                        } icon: {
                            Image(systemName: "person.circle")
                                .foregroundColor(.appPrimary)
                        }
                        .padding(.vertical, Spacing.xs)
                    }
                }

                Section("Social") {
                    NavigationLink {
                        Text("Coming soon")
                    } label: {
                        Label {
                            VStack(alignment: .leading, spacing: Spacing.xxs) {
                                HStack {
                                    Text("Friends")
                                        .font(.appTitle)
                                    if appState.pendingFriendRequests > 0 {
                                        Text("\(appState.pendingFriendRequests)")
                                            .font(.appCaption)
                                            .foregroundColor(.white)
                                            .padding(.horizontal, Spacing.xs)
                                            .padding(.vertical, 2)
                                            .background(Color.appPrimary)
                                            .clipShape(Capsule())
                                    }
                                }
                                Text("Friends and player search")
                                    .font(.appCaption)
                                    .foregroundColor(.appSecondary)
                            }
                        } icon: {
                            Image(systemName: "person.2")
                                .foregroundColor(.appPrimary)
                        }
                        .padding(.vertical, Spacing.xs)
                    }
                }

                Section("Learn") {
                    NavigationLink {
                        RulesReferenceView()
                    } label: {
                        Label {
                            VStack(alignment: .leading, spacing: Spacing.xxs) {
                                Text("Rules Reference")
                                    .font(.appTitle)
                                Text("Movement, support, convoy, retreats, and builds")
                                    .font(.appCaption)
                                    .foregroundColor(.appSecondary)
                            }
                        } icon: {
                            Image(systemName: "book")
                                .foregroundColor(.appPrimary)
                        }
                        .padding(.vertical, Spacing.xs)
                    }
                }
            }
            .navigationTitle("Profile")
        }
    }
}
