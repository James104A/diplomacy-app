import SwiftUI

struct BadgeView: View {
    let count: Int

    var body: some View {
        if count > 0 {
            Text(count > 99 ? "99+" : "\(count)")
                .font(.appBadge)
                .foregroundColor(.white)
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(Color.appError)
                .clipShape(Capsule())
                .accessibilityLabel("\(count) unread")
        }
    }
}
