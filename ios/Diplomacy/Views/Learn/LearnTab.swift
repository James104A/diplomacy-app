import SwiftUI

struct LearnTab: View {
    var body: some View {
        NavigationStack {
            List {
                NavigationLink {
                    RulesReferenceView()
                } label: {
                    Label {
                        VStack(alignment: .leading, spacing: Spacing.xxs) {
                            Text("Rules Reference")
                                .font(.appTitle)
                            Text("Movement, support, convoy, retreats, and builds")
                                .font(.appCaption)
                                .foregroundColor(.appSecondary)
                        }
                    } icon: {
                        Image(systemName: "book")
                            .foregroundColor(.appPrimary)
                    }
                    .padding(.vertical, Spacing.xs)
                }
            }
            .navigationTitle("Learn")
        }
    }
}
