import SwiftUI
import Combine

struct GameLobbyView: View {
    let gameId: UUID
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) private var dismiss

    @State private var game: GameResponse?
    @State private var isLoading = true
    @State private var errorMessage: String?
    @State private var cancellable: AnyCancellable?

    var body: some View {
        NavigationStack {
            Group {
                if isLoading {
                    ProgressView("Loading lobby...")
                } else if let game {
                    lobbyContent(game)
                } else {
                    errorView
                }
            }
            .navigationTitle("Game Lobby")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") { dismiss() }
                }
            }
            .task {
                await loadGame()
                subscribeToUpdates()
            }
            .onDisappear {
                cancellable?.cancel()
            }
        }
    }

    private func lobbyContent(_ game: GameResponse) -> some View {
        VStack(spacing: Spacing.lg) {
            // Game name
            Text(game.name)
                .font(.appScreenTitle)
                .padding(.top, Spacing.lg)

            // Player count
            Text("\(game.players.count) / 7 Players")
                .font(.appSectionHeader)
                .foregroundColor(.appPrimary)

            // Player slots
            VStack(spacing: Spacing.xs) {
                ForEach(game.players) { player in
                    HStack(spacing: Spacing.sm) {
                        Image(systemName: "person.fill")
                            .foregroundColor(.appSuccess)
                        if let power = player.powerEnum {
                            Circle()
                                .fill(power.color())
                                .frame(width: 12, height: 12)
                            Text(power.displayName)
                                .font(.appSecondaryBold)
                        } else {
                            Text("Joined")
                                .font(.appSecondaryBold)
                        }
                        Spacer()
                    }
                    .padding(.vertical, Spacing.xs)
                }

                // Empty slots
                ForEach(0..<(7 - game.players.count), id: \.self) { _ in
                    HStack(spacing: Spacing.sm) {
                        Image(systemName: "person.badge.plus")
                            .foregroundColor(.appSecondary.opacity(0.4))
                        Text("Waiting...")
                            .font(.appSecondary)
                            .foregroundColor(.appSecondary.opacity(0.5))
                        Spacer()
                    }
                    .padding(.vertical, Spacing.xs)
                }
            }
            .padding(.horizontal, Spacing.xl)

            // Settings summary
            VStack(spacing: Spacing.xs) {
                settingRow("Phase Length", value: game.settings.phaseLengthDisplay)
                settingRow("Press Rules", value: game.settings.pressRulesDisplay)
                settingRow("Status", value: game.status == "WAITING_FOR_PLAYERS" ? "Waiting" : game.status)
            }
            .padding(Spacing.md)
            .background(
                RoundedRectangle(cornerRadius: Spacing.xs)
                    .fill(Color.appGroupedBackground)
            )
            .padding(.horizontal, Spacing.xl)

            Spacer()

            // Share invite button
            if let inviteCode = game.inviteCode {
                ShareLink(
                    item: URL(string: "diplomacy://join/\(inviteCode)")!,
                    subject: Text("Join my Diplomacy game"),
                    message: Text("Join \"\(game.name)\" on Diplomacy!")
                ) {
                    Label("Share Invite Link", systemImage: "square.and.arrow.up")
                        .font(.appSecondaryBold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(minHeight: Spacing.touchTarget)
                        .background(Color.appPrimary)
                        .cornerRadius(Spacing.xs)
                }
                .padding(.horizontal, Spacing.xl)
                .padding(.bottom, Spacing.xxl)
            }
        }
    }

    private var errorView: some View {
        VStack(spacing: Spacing.md) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 48))
                .foregroundColor(.appError)
            Text(errorMessage ?? "Could not load game.")
                .font(.appSecondary)
                .foregroundColor(.appSecondary)
        }
        .padding(Spacing.xl)
    }

    private func settingRow(_ label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(.appSecondary)
                .foregroundColor(.appSecondary)
            Spacer()
            Text(value)
                .font(.appSecondaryBold)
        }
    }

    private func loadGame() async {
        do {
            game = try await GameService.shared.getGame(id: gameId)
        } catch {
            errorMessage = "Failed to load game."
        }
        isLoading = false
    }

    private func subscribeToUpdates() {
        cancellable = WebSocketManager.shared.eventPublisher
            .receive(on: DispatchQueue.main)
            .sink { event in
                guard event.gameId == gameId.uuidString else { return }
                switch event.event {
                case "game.player_joined", "game.started":
                    Task { await loadGame() }
                default:
                    break
                }
            }
    }
}
