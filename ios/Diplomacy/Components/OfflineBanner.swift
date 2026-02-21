import SwiftUI

struct OfflineBanner: View {
    @ObservedObject private var networkMonitor = NetworkMonitor.shared

    var body: some View {
        if !networkMonitor.isConnected {
            HStack(spacing: Spacing.xs) {
                Image(systemName: "wifi.slash")
                    .font(.appCaption)
                Text("No internet connection")
                    .font(.appCaption)
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, Spacing.xs)
            .background(Color.appSecondary)
            .transition(.move(edge: .top).combined(with: .opacity))
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("Offline. No internet connection.")
        }
    }
}
