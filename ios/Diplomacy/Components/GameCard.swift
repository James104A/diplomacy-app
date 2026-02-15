import SwiftUI

// MARK: - Game Card State Priority

enum GameCardState: Int, Comparable {
    case needsOrders = 1
    case unreadMessages = 2
    case ordersSubmitted = 3
    case waitingForResolution = 4
    case eliminated = 5

    static func < (lhs: GameCardState, rhs: GameCardState) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}

// MARK: - Game Card View

struct GameCard: View {
    let gameName: String
    let power: Power
    let phaseLabel: String
    let deadline: Date?
    let unreadCount: Int
    let ordersSubmitted: Bool
    let supplyCenterCount: Int
    let prevSupplyCenterCount: Int
    let isEliminated: Bool
    let palette: PowerPalette

    var state: GameCardState {
        if isEliminated { return .eliminated }
        if !ordersSubmitted && deadline != nil { return .needsOrders }
        if unreadCount > 0 { return .unreadMessages }
        if ordersSubmitted { return .ordersSubmitted }
        return .waitingForResolution
    }

    var body: some View {
        HStack(spacing: Spacing.sm) {
            // Left accent bar
            Rectangle()
                .fill(accentColor)
                .frame(width: 4)

            VStack(alignment: .leading, spacing: Spacing.xs) {
                // Top row: game name + badge
                HStack {
                    Text(gameName)
                        .font(.appTitle)
                        .foregroundColor(.primary)
                        .lineLimit(1)
                    Spacer()
                    BadgeView(count: unreadCount)
                }

                // Power indicator
                HStack(spacing: Spacing.xxs) {
                    Circle()
                        .fill(power.color(palette: palette))
                        .frame(width: 10, height: 10)
                    Text(power.displayName)
                        .font(.appSecondary)
                        .foregroundColor(.appSecondary)
                }

                // Phase label
                Text(phaseLabel)
                    .font(.appSecondary)
                    .foregroundColor(.appSecondary)

                // Bottom row: deadline + order status + SC count
                HStack {
                    if let deadline = deadline {
                        DeadlineTimerView(deadline: deadline)
                    }
                    Spacer()
                    orderStatusIcon
                    supplyCenterView
                }
            }
            .padding(.vertical, Spacing.sm)
            .padding(.trailing, Spacing.md)
        }
        .background(Color.appBackground)
        .cornerRadius(Spacing.xs)
        .shadow(color: .black.opacity(0.08), radius: 4, y: 2)
        .opacity(isEliminated ? 0.5 : 1.0)
        .overlay(eliminatedOverlay)
    }

    private var accentColor: Color {
        switch state {
        case .needsOrders: return .appWarning
        case .ordersSubmitted: return .appSuccess
        default: return .clear
        }
    }

    @ViewBuilder
    private var orderStatusIcon: some View {
        if isEliminated {
            EmptyView()
        } else if ordersSubmitted {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.appSuccess)
        } else if deadline != nil {
            Image(systemName: "exclamationmark.circle.fill")
                .foregroundColor(.appWarning)
        }
    }

    private var supplyCenterView: some View {
        HStack(spacing: 2) {
            Text("\(supplyCenterCount)")
                .font(.appSecondaryBold)
            trendArrow
        }
    }

    @ViewBuilder
    private var trendArrow: some View {
        let diff = supplyCenterCount - prevSupplyCenterCount
        if diff > 0 {
            Image(systemName: "arrow.up")
                .font(.appCaption)
                .foregroundColor(.appSuccess)
        } else if diff < 0 {
            Image(systemName: "arrow.down")
                .font(.appCaption)
                .foregroundColor(.appError)
        } else {
            Image(systemName: "minus")
                .font(.appCaption)
                .foregroundColor(.appSecondary)
        }
    }

    @ViewBuilder
    private var eliminatedOverlay: some View {
        if isEliminated {
            Text("Eliminated")
                .font(.appTitle)
                .foregroundColor(.appSecondary)
                .padding(Spacing.xs)
                .background(.ultraThinMaterial)
                .cornerRadius(Spacing.xxs)
        }
    }
}

// MARK: - Deadline Timer

struct DeadlineTimerView: View {
    let deadline: Date

    @State private var timeRemaining: TimeInterval = 0

    var body: some View {
        Text(formattedTime)
            .font(.appSecondaryBold)
            .foregroundColor(urgencyColor)
            .onAppear { updateTime() }
    }

    private func updateTime() {
        timeRemaining = max(0, deadline.timeIntervalSinceNow)
    }

    private var formattedTime: String {
        let hours = Int(timeRemaining) / 3600
        let minutes = (Int(timeRemaining) % 3600) / 60
        if hours > 24 {
            return "\(hours / 24)d \(hours % 24)h"
        }
        return "\(hours)h \(minutes)m"
    }

    private var urgencyColor: Color {
        let hours = timeRemaining / 3600
        if hours > 12 { return .deadlineGreen }
        if hours > 2 { return .deadlineYellow }
        return .deadlineRed
    }
}
