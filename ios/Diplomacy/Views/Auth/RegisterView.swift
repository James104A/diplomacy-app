import SwiftUI

struct RegisterView: View {
    @EnvironmentObject var appState: AppState

    @State private var email = ""
    @State private var displayName = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var isLoading = false
    @State private var errorMessage: String?

    @FocusState private var focusedField: Field?

    private enum Field {
        case email, displayName, password, confirmPassword
    }

    var body: some View {
        ScrollView {
            VStack(spacing: Spacing.lg) {
                // Header
                VStack(spacing: Spacing.xs) {
                    Text("Create Account")
                        .font(.appScreenTitle)
                    Text("Join the world of Diplomacy")
                        .font(.appSecondary)
                        .foregroundColor(.appSecondary)
                }
                .padding(.top, Spacing.xl)

                // Form fields
                VStack(spacing: Spacing.md) {
                    AuthTextField(
                        title: "Email",
                        text: $email,
                        placeholder: "you@example.com",
                        keyboardType: .emailAddress,
                        textContentType: .emailAddress
                    )
                    .focused($focusedField, equals: .email)
                    .submitLabel(.next)
                    .onSubmit { focusedField = .displayName }

                    AuthTextField(
                        title: "Display Name",
                        text: $displayName,
                        placeholder: "3-50 characters",
                        textContentType: .name
                    )
                    .focused($focusedField, equals: .displayName)
                    .submitLabel(.next)
                    .onSubmit { focusedField = .password }

                    AuthTextField(
                        title: "Password",
                        text: $password,
                        placeholder: "8+ characters",
                        isSecure: true,
                        textContentType: .newPassword
                    )
                    .focused($focusedField, equals: .password)
                    .submitLabel(.next)
                    .onSubmit { focusedField = .confirmPassword }

                    // Password strength indicator
                    PasswordStrengthView(password: password)

                    AuthTextField(
                        title: "Confirm Password",
                        text: $confirmPassword,
                        placeholder: "Re-enter password",
                        isSecure: true,
                        textContentType: .newPassword
                    )
                    .focused($focusedField, equals: .confirmPassword)
                    .submitLabel(.done)
                    .onSubmit { register() }
                }
                .padding(.horizontal, Spacing.xl)

                // Error message
                if let errorMessage {
                    Text(errorMessage)
                        .font(.appCaption)
                        .foregroundColor(.appError)
                        .padding(.horizontal, Spacing.xl)
                }

                // Register button
                VStack(spacing: Spacing.sm) {
                    DiplomacyButton(
                        title: isLoading ? "Creating Account..." : "Create Account",
                        style: isFormValid ? .primary : .disabled
                    ) {
                        register()
                    }
                    .disabled(isLoading)
                }
                .padding(.horizontal, Spacing.xl)
                .padding(.bottom, Spacing.xxl)
            }
        }
        .background(Color.appBackground)
        .navigationBarTitleDisplayMode(.inline)
    }

    private var isFormValid: Bool {
        !email.isEmpty &&
        !displayName.isEmpty && displayName.count >= 3 &&
        !password.isEmpty && password.count >= 8 &&
        password == confirmPassword
    }

    private func register() {
        guard isFormValid, !isLoading else { return }

        focusedField = nil
        isLoading = true
        errorMessage = nil

        Task {
            do {
                let response = try await AuthService.shared.register(
                    email: email,
                    password: password,
                    displayName: displayName
                )
                appState.isAuthenticated = true
            } catch let error as NetworkError {
                errorMessage = error.errorDescription
            } catch {
                errorMessage = "Something went wrong. Please try again."
            }
            isLoading = false
        }
    }
}

// MARK: - Password Strength

struct PasswordStrengthView: View {
    let password: String

    private var strength: PasswordStrength {
        PasswordStrength.evaluate(password)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.xxs) {
            HStack(spacing: Spacing.xxs) {
                ForEach(0..<4, id: \.self) { index in
                    RoundedRectangle(cornerRadius: 2)
                        .fill(index < strength.level ? strength.color : Color.gray.opacity(0.2))
                        .frame(height: 4)
                }
            }

            if !password.isEmpty {
                Text(strength.label)
                    .font(.appCaption)
                    .foregroundColor(strength.color)
            }
        }
    }
}

enum PasswordStrength {
    case weak, fair, good, strong

    var level: Int {
        switch self {
        case .weak: return 1
        case .fair: return 2
        case .good: return 3
        case .strong: return 4
        }
    }

    var label: String {
        switch self {
        case .weak: return "Weak"
        case .fair: return "Fair"
        case .good: return "Good"
        case .strong: return "Strong"
        }
    }

    var color: Color {
        switch self {
        case .weak: return .appError
        case .fair: return .appWarning
        case .good: return .appPrimary
        case .strong: return .appSuccess
        }
    }

    static func evaluate(_ password: String) -> PasswordStrength {
        guard !password.isEmpty else { return .weak }

        var score = 0
        if password.count >= 8 { score += 1 }
        if password.count >= 12 { score += 1 }
        if password.range(of: "[A-Z]", options: .regularExpression) != nil { score += 1 }
        if password.range(of: "[0-9]", options: .regularExpression) != nil { score += 1 }
        if password.range(of: "[^A-Za-z0-9]", options: .regularExpression) != nil { score += 1 }

        switch score {
        case 0...1: return .weak
        case 2: return .fair
        case 3: return .good
        default: return .strong
        }
    }
}
