import SwiftUI

struct JoinGameSheet: View {
    let inviteCode: String
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) private var dismiss

    @State private var game: GameResponse?
    @State private var isLoadingPreview = true
    @State private var isJoining = false
    @State private var errorMessage: String?
    @State private var joinedGame: GameResponse?

    var body: some View {
        NavigationStack {
            Group {
                if let joinedGame {
                    joinedView(joinedGame)
                } else if isLoadingPreview {
                    ProgressView("Loading game info...")
                } else if let game {
                    previewView(game)
                } else {
                    errorOnlyView
                }
            }
            .navigationTitle("Join Game")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
            }
            .task {
                await loadGamePreview()
            }
        }
    }

    private func previewView(_ game: GameResponse) -> some View {
        VStack(spacing: Spacing.lg) {
            Spacer()

            Image(systemName: "person.badge.plus")
                .font(.system(size: 48))
                .foregroundColor(.appPrimary)

            Text(game.name)
                .font(.appScreenTitle)

            // Game settings
            VStack(spacing: Spacing.xs) {
                settingRow("Phase Length", value: game.settings.phaseLengthDisplay)
                settingRow("Press Rules", value: game.settings.pressRulesDisplay)
                settingRow("Players", value: "\(game.players.count) / 7")
            }
            .padding(Spacing.md)
            .background(
                RoundedRectangle(cornerRadius: Spacing.xs)
                    .fill(Color.appGroupedBackground)
            )
            .padding(.horizontal, Spacing.xl)

            if let errorMessage {
                Text(errorMessage)
                    .font(.appCaption)
                    .foregroundColor(.appError)
            }

            Spacer()

            DiplomacyButton(
                title: isJoining ? "Joining..." : "Join Game",
                style: .primary
            ) {
                joinGame()
            }
            .disabled(isJoining)
            .padding(.horizontal, Spacing.xl)
            .padding(.bottom, Spacing.xxl)
        }
    }

    private func joinedView(_ game: GameResponse) -> some View {
        VStack(spacing: Spacing.lg) {
            Spacer()

            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 64))
                .foregroundColor(.appSuccess)

            Text("Joined!")
                .font(.appScreenTitle)

            Text(game.name)
                .font(.appTitle)
                .foregroundColor(.appSecondary)

            Text("\(game.players.count) / 7 players")
                .font(.appSecondary)
                .foregroundColor(.appSecondary)

            Spacer()

            DiplomacyButton(title: "Done", style: .success) {
                dismiss()
            }
            .padding(.horizontal, Spacing.xl)
            .padding(.bottom, Spacing.xxl)
        }
    }

    private var errorOnlyView: some View {
        VStack(spacing: Spacing.md) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 48))
                .foregroundColor(.appError)
            Text(errorMessage ?? "Could not load game.")
                .font(.appSecondary)
                .foregroundColor(.appSecondary)
                .multilineTextAlignment(.center)
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

    private func loadGamePreview() async {
        do {
            // Use join endpoint to preview — the backend returns game info
            // We'll use a GET-like approach; for now fetch by invite code
            game = try await GameService.shared.getGameByInviteCode(inviteCode)
        } catch {
            errorMessage = "Could not find game with this invite code."
        }
        isLoadingPreview = false
    }

    private func joinGame() {
        guard !isJoining else { return }
        isJoining = true
        errorMessage = nil

        Task {
            do {
                joinedGame = try await GameService.shared.joinGame(inviteCode: inviteCode)
            } catch let error as NetworkError {
                switch error {
                case .conflict:
                    errorMessage = "You've already joined this game."
                default:
                    errorMessage = error.errorDescription
                }
            } catch {
                errorMessage = "Failed to join game."
            }
            isJoining = false
        }
    }
}
