import SwiftUI

struct PlayerRosterView: View {
    let players: [GamePlayerSummary]
    let units: [UnitDto]
    let myPower: String
    let palette: PowerPalette

    private func unitCount(for power: String) -> Int {
        units.filter { $0.power == power }.count
    }

    private var sortedPlayers: [GamePlayerSummary] {
        players.sorted { a, b in
            if a.isEliminated != b.isEliminated {
                return !a.isEliminated
            }
            return a.supplyCenterCount > b.supplyCenterCount
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Spacing.xs) {
                    ForEach(sortedPlayers) { player in
                        playerRow(player)
                    }
                }
                .padding(.horizontal, Spacing.md)
                .padding(.top, Spacing.sm)
            }
            .navigationTitle("Players")
            .navigationBarTitleDisplayMode(.inline)
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
        }
    }

    private func playerRow(_ player: GamePlayerSummary) -> some View {
        let power = Power(rawValue: player.power)
        let color = power?.color(palette: palette) ?? .gray
        let abbrev = String(player.power.prefix(3)).uppercased()
        let scCount = player.supplyCenterCount
        let units = unitCount(for: player.power)
        let isMe = player.power == myPower

        return VStack(spacing: 0) {
            HStack(spacing: Spacing.sm) {
                // Power badge
                ZStack {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(color)
                        .frame(width: 44, height: 44)

                    if let power {
                        PatternOverlay(power: power, size: CGSize(width: 44, height: 44))
                            .clipShape(RoundedRectangle(cornerRadius: 6))
                    }

                    Text(abbrev)
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.5), radius: 1, x: 0, y: 1)

                    // "Me" indicator
                    if isMe {
                        Circle()
                            .fill(Color.yellow)
                            .frame(width: 10, height: 10)
                            .overlay(Circle().stroke(Color.white, lineWidth: 1.5))
                            .offset(x: 17, y: -17)
                    }
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(player.playerId.uuidString.prefix(8))
                        .font(.appTitle)
                    Text(power?.displayName ?? player.power.capitalized)
                        .font(.appCaption)
                        .foregroundColor(.appSecondary)
                    if player.isEliminated {
                        Text("Eliminated")
                            .font(.appCaption)
                            .foregroundColor(.appError)
                    }
                }

                Spacer()

                // Stats
                HStack(spacing: Spacing.md) {
                    VStack(spacing: 2) {
                        Text("\(scCount)")
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                        Text("SC")
                            .font(.appCaption)
                            .foregroundColor(.appSecondary)
                    }

                    VStack(spacing: 2) {
                        Text("\(units)")
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                        Text("Units")
                            .font(.appCaption)
                            .foregroundColor(.appSecondary)
                    }
                }
            }
            .padding(Spacing.sm)

            // SC progress bar toward 18 (solo win)
            GeometryReader { geo in
                RoundedRectangle(cornerRadius: 1.5)
                    .fill(color)
                    .frame(width: geo.size.width * CGFloat(scCount) / 18.0, height: 3)
            }
            .frame(height: 3)
            .padding(.horizontal, Spacing.sm)
            .padding(.bottom, Spacing.xs)
        }
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(10)
        .opacity(player.isEliminated ? 0.4 : 1.0)
    }
}
