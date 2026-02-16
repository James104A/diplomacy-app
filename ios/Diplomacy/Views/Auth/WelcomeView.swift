import SwiftUI

struct WelcomeView: View {
    @EnvironmentObject var appState: AppState

    @State private var showLogin = false
    @State private var showRegister = false

    var body: some View {
        NavigationStack {
            VStack(spacing: Spacing.xxl) {
                Spacer()

                // Logo / title area
                VStack(spacing: Spacing.sm) {
                    Image(systemName: "globe.europe.africa")
                        .font(.system(size: 80))
                        .foregroundColor(.appPrimary)

                    Text("Diplomacy")
                        .font(.system(size: 36, weight: .bold))

                    Text("The classic game of strategy and negotiation")
                        .font(.appSecondary)
                        .foregroundColor(.appSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, Spacing.xl)
                }

                Spacer()

                // Auth buttons
                VStack(spacing: Spacing.sm) {
                    DiplomacyButton(title: "Create Account", style: .primary) {
                        showRegister = true
                    }

                    DiplomacyButton(title: "Sign In", style: .success) {
                        showLogin = true
                    }

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

                    AppleSignInButton()
                }
                .padding(.horizontal, Spacing.xl)
                .padding(.bottom, Spacing.xxl)
            }
            .background(Color.appBackground)
            .navigationDestination(isPresented: $showLogin) {
                LoginView()
            }
            .navigationDestination(isPresented: $showRegister) {
                RegisterView()
            }
        }
    }
}
