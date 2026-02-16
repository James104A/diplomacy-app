import SwiftUI
import AuthenticationServices

struct AppleSignInButton: View {
    @EnvironmentObject var appState: AppState

    @State private var errorMessage: String?
    @State private var isLoading = false

    var body: some View {
        VStack(spacing: Spacing.xs) {
            SignInWithAppleButton(.signIn) { request in
                request.requestedScopes = [.email, .fullName]
            } onCompletion: { result in
                handleResult(result)
            }
            .signInWithAppleButtonStyle(.black)
            .frame(height: Spacing.touchTarget)
            .cornerRadius(Spacing.xs)
            .disabled(isLoading)

            if let errorMessage {
                Text(errorMessage)
                    .font(.appCaption)
                    .foregroundColor(.appError)
            }
        }
    }

    private func handleResult(_ result: Result<ASAuthorization, Error>) {
        switch result {
        case .success(let authorization):
            guard let credential = authorization.credential as? ASAuthorizationAppleIDCredential,
                  let identityTokenData = credential.identityToken,
                  let idToken = String(data: identityTokenData, encoding: .utf8) else {
                errorMessage = "Could not get Apple credentials."
                return
            }

            let displayName: String?
            if let givenName = credential.fullName?.givenName {
                let familyName = credential.fullName?.familyName ?? ""
                displayName = "\(givenName) \(familyName)".trimmingCharacters(in: .whitespaces)
            } else {
                displayName = nil
            }

            isLoading = true
            errorMessage = nil

            Task {
                do {
                    let response = try await AuthService.shared.loginWithApple(
                        idToken: idToken,
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

        case .failure(let error):
            // ASAuthorizationError.canceled = user dismissed the sheet
            if (error as? ASAuthorizationError)?.code == .canceled { return }
            errorMessage = "Apple Sign In failed."
        }
    }
}
