import SwiftUI

struct GamesTab: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: Spacing.md) {
                Image(systemName: "swords")
                    .font(.system(size: 48))
                    .foregroundColor(.appPrimary)
                Text("Games")
                    .font(.appScreenTitle)
                Text("Your active games will appear here")
                    .font(.appSecondary)
                    .foregroundColor(.appSecondary)
            }
            .navigationTitle("Games")
        }
    }
}
