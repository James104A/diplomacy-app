import SwiftUI

struct CreateGameView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) private var dismiss

    @State private var gameName = ""
    @State private var phaseLength: PhaseLength = .twentyFourHours
    @State private var pressRules: PressRules = .fullPress
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var createdGame: GameResponse?

    var body: some View {
        NavigationStack {
            Group {
                if let game = createdGame {
                    gameCreatedView(game)
                } else {
                    formView
                }
            }
            .navigationTitle("Create Game")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }

    private var formView: some View {
        Form {
            Section("Game Name") {
                TextField("e.g. Western Front 1901", text: $gameName)
                    .textInputAutocapitalization(.words)
            }

            Section("Phase Length") {
                Picker("Turn Duration", selection: $phaseLength) {
                    ForEach(PhaseLength.allCases) { length in
                        Text(length.displayName).tag(length)
                    }
                }
                .pickerStyle(.menu)
            }

            Section {
                Picker("Press Rules", selection: $pressRules) {
                    ForEach(PressRules.allCases) { rules in
                        Text(rules.displayName).tag(rules)
                    }
                }
                .pickerStyle(.menu)

                Text(pressRules.description)
                    .font(.appCaption)
                    .foregroundColor(.appSecondary)
            } header: {
                Text("Communication")
            }

            Section {
                if let errorMessage {
                    Text(errorMessage)
                        .font(.appCaption)
                        .foregroundColor(.appError)
                }

                DiplomacyButton(
                    title: isLoading ? "Creating..." : "Create Game",
                    style: gameName.trimmingCharacters(in: .whitespaces).count >= 3 ? .primary : .disabled
                ) {
                    createGame()
                }
                .disabled(isLoading)
                .listRowInsets(EdgeInsets())
                .listRowBackground(Color.clear)
            }
        }
    }

    private func gameCreatedView(_ game: GameResponse) -> some View {
        VStack(spacing: Spacing.xl) {
            Spacer()

            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 64))
                .foregroundColor(.appSuccess)

            Text("Game Created!")
                .font(.appScreenTitle)

            Text(game.name)
                .font(.appTitle)
                .foregroundColor(.appSecondary)

            if let inviteCode = game.inviteCode {
                VStack(spacing: Spacing.sm) {
                    Text("Invite Code")
                        .font(.appSecondaryBold)
                    Text(inviteCode)
                        .font(.system(size: 24, weight: .bold, design: .monospaced))
                        .foregroundColor(.appPrimary)
                }
                .padding(Spacing.md)
                .background(
                    RoundedRectangle(cornerRadius: Spacing.xs)
                        .fill(Color.appGroupedBackground)
                )

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
            }

            Spacer()

            DiplomacyButton(title: "Done", style: .success) {
                dismiss()
            }
            .padding(.horizontal, Spacing.xl)
            .padding(.bottom, Spacing.xxl)
        }
    }

    private func createGame() {
        let trimmedName = gameName.trimmingCharacters(in: .whitespaces)
        guard trimmedName.count >= 3, !isLoading else { return }

        isLoading = true
        errorMessage = nil

        Task {
            do {
                let request = CreateGameRequest(
                    name: trimmedName,
                    phaseLength: phaseLength.rawValue,
                    pressRules: pressRules.rawValue,
                    visibility: "PRIVATE"
                )
                createdGame = try await GameService.shared.createGame(request)
            } catch let error as NetworkError {
                errorMessage = error.errorDescription
            } catch {
                errorMessage = "Failed to create game."
            }
            isLoading = false
        }
    }
}
