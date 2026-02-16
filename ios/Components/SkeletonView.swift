import SwiftUI

// MARK: - Shimmer Modifier

struct ShimmerModifier: ViewModifier {
    @State private var phase: CGFloat = 0

    func body(content: Content) -> some View {
        content
            .overlay(
                LinearGradient(
                    gradient: Gradient(colors: [
                        .clear,
                        .white.opacity(0.4),
                        .clear
                    ]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .rotationEffect(.degrees(20))
                .offset(x: phase)
                .onAppear {
                    withAnimation(
                        .linear(duration: 1.5)
                        .repeatForever(autoreverses: false)
                    ) {
                        phase = 400
                    }
                }
            )
            .clipped()
    }
}

extension View {
    func shimmer() -> some View {
        modifier(ShimmerModifier())
    }
}

// MARK: - Skeleton Shapes

struct SkeletonRect: View {
    var width: CGFloat? = nil
    var height: CGFloat = 16
    var cornerRadius: CGFloat = 4

    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius)
            .fill(Color.gray.opacity(0.2))
            .frame(width: width, height: height)
            .shimmer()
    }
}

struct SkeletonCircle: View {
    var size: CGFloat = 40

    var body: some View {
        Circle()
            .fill(Color.gray.opacity(0.2))
            .frame(width: size, height: size)
            .shimmer()
    }
}

// MARK: - Skeleton Game Card

struct SkeletonGameCard: View {
    var body: some View {
        HStack(spacing: Spacing.sm) {
            Rectangle()
                .fill(Color.gray.opacity(0.15))
                .frame(width: 4)

            VStack(alignment: .leading, spacing: Spacing.xs) {
                SkeletonRect(width: 180, height: 16)
                HStack(spacing: Spacing.xxs) {
                    SkeletonCircle(size: 10)
                    SkeletonRect(width: 80, height: 14)
                }
                SkeletonRect(width: 140, height: 14)
                HStack {
                    SkeletonRect(width: 60, height: 14)
                    Spacer()
                    SkeletonRect(width: 30, height: 14)
                }
            }
            .padding(.vertical, Spacing.sm)
            .padding(.trailing, Spacing.md)
        }
        .background(Color.appBackground)
        .cornerRadius(Spacing.xs)
        .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
    }
}

// MARK: - Skeleton Dashboard

struct SkeletonDashboard: View {
    var body: some View {
        VStack(spacing: Spacing.sm) {
            ForEach(0..<4, id: \.self) { _ in
                SkeletonGameCard()
            }
        }
        .padding(.horizontal, Spacing.md)
    }
}

// MARK: - Skeleton Messages

struct SkeletonMessageBubble: View {
    let isRight: Bool

    var body: some View {
        HStack {
            if isRight { Spacer() }
            SkeletonRect(width: CGFloat.random(in: 120...220), height: 36, cornerRadius: 12)
            if !isRight { Spacer() }
        }
    }
}

struct SkeletonMessages: View {
    var body: some View {
        VStack(spacing: Spacing.xs) {
            ForEach(0..<8, id: \.self) { i in
                SkeletonMessageBubble(isRight: i % 3 == 0)
            }
        }
        .padding(.horizontal, Spacing.md)
    }
}
