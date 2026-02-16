import SwiftUI

struct LoginView: View {
    @EnvironmentObject var appState: AppState

    @State private var email = ""
    @State private var password = ""
    @State private var isLoading = false
    @State private var errorMessage: String?

    @FocusState private var focusedField: Field?

    private enum Field {
        case email, password
    }

    var body: some View {
        ScrollView {
            VStack(spacing: Spacing.lg) {
                // Header
                VStack(spacing: Spacing.xs) {
                    Text("Sign In")
                        .font(.appScreenTitle)
                    Text("Welcome back, diplomat")
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
                    .onSubmit { focusedField = .password }

                    AuthTextField(
                        title: "Password",
                        text: $password,
                        placeholder: "Enter your password",
                        isSecure: true,
                        textContentType: .password
                    )
                    .focused($focusedField, equals: .password)
                    .submitLabel(.go)
                    .onSubmit { login() }
                }
                .padding(.horizontal, Spacing.xl)

                // Error message
                if let errorMessage {
                    Text(errorMessage)
                        .font(.appCaption)
                        .foregroundColor(.appError)
                        .padding(.horizontal, Spacing.xl)
                }

                // Login button
                DiplomacyButton(
                    title: isLoading ? "Signing In..." : "Sign In",
                    style: isFormValid ? .primary : .disabled
                ) {
                    login()
                }
                .disabled(isLoading)
                .padding(.horizontal, Spacing.xl)

                // Divider
                HStack {
                    Rectangle()
                        .fill(Color.appSecondary.opacity(0.3))
                        .frame(height: 1)
                    Text("or")
                        .font(.appCaption)
                        .foregroundColor(.appSecondary)
                    Rectangle()
                        .fill(Color.appSecondary.opacity(0.3))
                        .frame(height: 1)
                }
                .padding(.horizontal, Spacing.xl)

                // Apple Sign In
                AppleSignInButton()
                    .padding(.horizontal, Spacing.xl)

                Spacer()
            }
        }
        .background(Color.appBackground)
        .navigationBarTitleDisplayMode(.inline)
    }

    private var isFormValid: Bool {
        !email.isEmpty && !password.isEmpty
    }

    private func login() {
        guard isFormValid, !isLoading else { return }

        focusedField = nil
        isLoading = true
        errorMessage = nil

        Task {
            do {
                let response = try await AuthService.shared.login(
                    email: email,
                    password: password
                )
                appState.isAuthenticated = true
            } catch let error as NetworkError {
                switch error {
                case .unauthorized:
                    errorMessage = "Invalid email or password."
                default:
                    errorMessage = error.errorDescription
                }
            } catch {
                errorMessage = "Something went wrong. Please try again."
            }
            isLoading = false
        }
    }
}
