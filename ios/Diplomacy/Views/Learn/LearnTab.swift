import SwiftUI

struct LearnTab: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: Spacing.md) {
                Image(systemName: "graduationcap")
                    .font(.system(size: 48))
                    .foregroundColor(.appPrimary)
                Text("Learn")
                    .font(.appScreenTitle)
                Text("Rules reference and tutorials")
                    .font(.appSecondary)
                    .foregroundColor(.appSecondary)
            }
            .navigationTitle("Learn")
        }
    }
}
