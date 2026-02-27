import Foundation
import Combine

@MainActor
class NotificationSettingsViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var isSaving = false
    @Published var errorMessage: String?

    @Published var newMessage: Bool = true
    @Published var phaseResolved: PhaseResolvedOption = .immediate
    @Published var deadlineReminder: ReminderDuration = .twoHours
    @Published var ordersReminder: ReminderDuration = .fourHours

    private var fullPreferences: NotificationPreferences?
    private var cancellables = Set<AnyCancellable>()
    private var hasLoaded = false

    init() {
        setupAutoSave()
    }

    func loadPreferences() async {
        isLoading = true
        errorMessage = nil

        do {
            let prefs = try await NotificationService.shared.getPreferences()
            fullPreferences = prefs
            applyGlobalPrefs(prefs.global)
            hasLoaded = true
        } catch let error as NetworkError {
            errorMessage = error.errorDescription
        } catch {
            errorMessage = "Failed to load notification settings."
        }

        isLoading = false
    }

    // MARK: - Auto-Save

    private func setupAutoSave() {
        Publishers.CombineLatest4(
            $newMessage,
            $phaseResolved,
            $deadlineReminder,
            $ordersReminder
        )
        .dropFirst()
        .debounce(for: .milliseconds(500), scheduler: DispatchQueue.main)
        .sink { [weak self] _, _, _, _ in
            guard let self, self.hasLoaded else { return }
            Task { await self.savePreferences() }
        }
        .store(in: &cancellables)
    }

    private func savePreferences() async {
        guard var prefs = fullPreferences else { return }
        isSaving = true
        errorMessage = nil

        prefs.global = GlobalNotificationPrefs(
            newMessage: newMessage,
            phaseResolved: phaseResolved.rawValue,
            deadlineReminder: deadlineReminder.rawValue,
            ordersReminder: ordersReminder.rawValue
        )

        do {
            let updated = try await NotificationService.shared.updatePreferences(prefs)
            fullPreferences = updated
        } catch let error as NetworkError {
            errorMessage = error.errorDescription
        } catch {
            errorMessage = "Failed to save settings."
        }

        isSaving = false
    }

    // MARK: - Helpers

    private func applyGlobalPrefs(_ global: GlobalNotificationPrefs) {
        newMessage = global.newMessage
        phaseResolved = PhaseResolvedOption(rawValue: global.phaseResolved) ?? .immediate
        deadlineReminder = ReminderDuration(rawValue: global.deadlineReminder) ?? .twoHours
        ordersReminder = ReminderDuration(rawValue: global.ordersReminder) ?? .fourHours
    }
}
