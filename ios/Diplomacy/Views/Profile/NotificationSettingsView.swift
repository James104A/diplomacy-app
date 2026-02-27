import SwiftUI

struct NotificationSettingsView: View {
    @StateObject private var viewModel = NotificationSettingsViewModel()

    var body: some View {
        Group {
            if viewModel.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                formContent
            }
        }
        .navigationTitle("Notifications")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await viewModel.loadPreferences()
        }
    }

    private var formContent: some View {
        Form {
            if let errorMessage = viewModel.errorMessage {
                Section {
                    Text(errorMessage)
                        .font(.appCaption)
                        .foregroundColor(.appError)
                }
            }

            Section {
                Toggle("New messages", isOn: $viewModel.newMessage)
            } header: {
                Text("Messages")
            } footer: {
                Text("Get notified when you receive a new diplomatic message.")
            }

            Section {
                Picker("Phase resolved", selection: $viewModel.phaseResolved) {
                    ForEach(PhaseResolvedOption.allCases) { option in
                        Text(option.displayName).tag(option)
                    }
                }
                .pickerStyle(.menu)
            } header: {
                Text("Game Events")
            } footer: {
                Text("How you want to be notified when a game phase resolves.")
            }

            Section {
                Picker("Deadline reminder", selection: $viewModel.deadlineReminder) {
                    ForEach(ReminderDuration.allCases) { duration in
                        Text(duration.displayName).tag(duration)
                    }
                }
                .pickerStyle(.menu)

                Picker("Orders reminder", selection: $viewModel.ordersReminder) {
                    ForEach(ReminderDuration.allCases) { duration in
                        Text(duration.displayName).tag(duration)
                    }
                }
                .pickerStyle(.menu)
            } header: {
                Text("Reminders")
            } footer: {
                Text("Reminders are sent before the phase deadline if you haven't submitted orders.")
            }

            Section {
                VStack(alignment: .leading, spacing: Spacing.xs) {
                    Label("Always sent", systemImage: "info.circle")
                        .font(.appSecondaryBold)
                        .foregroundColor(.appPrimary)
                    Text("Game started, game ended, player eliminated, and draw proposed notifications cannot be disabled.")
                        .font(.appCaption)
                        .foregroundColor(.appSecondary)
                }
                .padding(.vertical, Spacing.xs)
            }

            if viewModel.isSaving {
                Section {
                    HStack(spacing: Spacing.xs) {
                        ProgressView()
                            .scaleEffect(0.8)
                        Text("Saving...")
                            .font(.appCaption)
                            .foregroundColor(.appSecondary)
                    }
                }
            }
        }
    }
}
