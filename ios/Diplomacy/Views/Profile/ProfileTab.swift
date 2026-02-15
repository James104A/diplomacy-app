import SwiftUI

struct ProfileTab: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: Spacing.md) {
                Image(systemName: "person.circle")
                    .font(.system(size: 48))
                    .foregroundColor(.appPrimary)
                Text("Profile")
                    .font(.appScreenTitle)
                Text("Stats, settings, and achievements")
                    .font(.appSecondary)
                    .foregroundColor(.appSecondary)
            }
            .navigationTitle("Profile")
        }
    }
}
