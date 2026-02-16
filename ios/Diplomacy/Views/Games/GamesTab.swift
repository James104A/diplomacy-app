import SwiftUI

struct GamesTab: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var viewModel = DashboardViewModel()
    @Environment(\.scenePhase) private var scenePhase

    @State private var showCreateGame = false
    @State private var selectedGame: GameSummary?

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading {
                    SkeletonDashboard()
                } else if let error = viewModel.errorMessage, viewModel.games.isEmpty {
                    errorView(error)
                } else if viewModel.games.isEmpty {
                    emptyView
                } else {
                    gamesList
                }
            }
            .navigationTitle("Games")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showCreateGame = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showCreateGame) {
                CreateGameView()
                    .environmentObject(appState)
            }
            .sheet(item: Binding(
                get: { selectedGame?.status == "WAITING_FOR_PLAYERS" ? selectedGame : nil },
                set: { _ in selectedGame = nil }
            )) { game in
                GameLobbyView(gameId: game.gameId)
                    .environmentObject(appState)
            }
            .navigationDestination(isPresented: Binding(
                get: { selectedGame != nil && selectedGame?.status != "WAITING_FOR_PLAYERS" },
                set: { if !$0 { selectedGame = nil } }
            )) {
                if let game = selectedGame {
                    GameView(gameId: game.gameId)
                        .environmentObject(appState)
                }
            }
            .task {
                await viewModel.loadGames()
                viewModel.subscribeToWebSocket()
            }
            .refreshable {
                await viewModel.loadGames()
            }
            .onChange(of: scenePhase) { newPhase in
                if newPhase == .active {
                    Task { await viewModel.loadGames() }
                }
            }
            .onChange(of: viewModel.attentionCount) { count in
                appState.gamesNeedingAttention = count
            }
            .onChange(of: viewModel.totalUnreadMessages) { count in
                appState.totalUnreadMessages = count
            }
        }
    }

    private var gamesList: some View {
        ScrollView {
            LazyVStack(spacing: Spacing.sm) {
                ForEach(viewModel.sortedGames) { game in
                    Button {
                        selectedGame = game
                    } label: {
                        GameCard(
                            gameName: game.name,
                            power: game.powerEnum ?? .england,
                            phaseLabel: game.phaseLabel,
                            deadline: game.phaseDeadline,
                            unreadCount: game.unreadMessageCount,
                            ordersSubmitted: game.ordersSubmitted,
                            supplyCenterCount: game.supplyCenterCount,
                            prevSupplyCenterCount: game.prevSupplyCenterCount,
                            isEliminated: game.isEliminated,
                            palette: .classic
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, Spacing.md)
            .padding(.top, Spacing.xs)
        }
    }

    private var emptyView: some View {
        VStack(spacing: Spacing.md) {
            Image(systemName: "swords")
                .font(.system(size: 48))
                .foregroundColor(.appSecondary.opacity(0.5))
            Text("No Games Yet")
                .font(.appSectionHeader)
            Text("Create a game or join one via invite link")
                .font(.appSecondary)
                .foregroundColor(.appSecondary)
                .multilineTextAlignment(.center)
            DiplomacyButton(title: "Create Game", style: .primary) {
                showCreateGame = true
            }
            .frame(width: 200)
        }
        .padding(Spacing.xl)
    }

    private func errorView(_ message: String) -> some View {
        VStack(spacing: Spacing.md) {
            Image(systemName: "wifi.slash")
                .font(.system(size: 48))
                .foregroundColor(.appError)
            Text(message)
                .font(.appSecondary)
                .foregroundColor(.appSecondary)
                .multilineTextAlignment(.center)
            DiplomacyButton(title: "Retry", style: .primary) {
                Task { await viewModel.loadGames() }
            }
            .frame(width: 200)
        }
        .padding(Spacing.xl)
    }
}
