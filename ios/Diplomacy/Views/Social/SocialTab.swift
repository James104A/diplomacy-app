import SwiftUI

struct SocialTab: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: Spacing.md) {
                Image(systemName: "person.2")
                    .font(.system(size: 48))
                    .foregroundColor(.appPrimary)
                Text("Social")
                    .font(.appScreenTitle)
                Text("Friends and player search")
                    .font(.appSecondary)
                    .foregroundColor(.appSecondary)
            }
            .navigationTitle("Social")
        }
    }
}
