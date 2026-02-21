import Foundation
import SwiftUI

@MainActor
class OrderEntryViewModel: ObservableObject {
    let gameId: UUID

    // Current orders
    @Published var orders: [OrderDto] = []
    @Published var undoStack: [OrderDto] = []

    // Active order entry state
    @Published var selectedUnit: UnitDto?
    @Published var selectedOrderType: OrderType?
    @Published var supportOrigin: String?
    @Published var showOrderPalette = false
    @Published var currentOrder: OrderDto?

    // Submission
    @Published var isSubmitted = false
    @Published var isSubmitting = false
    @Published var submissionError: String?
    @Published var validationResults: [OrderValidationResult] = []

    var isActive: Bool {
        selectedUnit != nil
    }

    init(gameId: UUID) {
        self.gameId = gameId
    }

    // MARK: - Available Order Types

    var availableOrderTypes: [OrderType] {
        guard let unit = selectedUnit else { return [] }
        var types: [OrderType] = [.hold, .move, .support]
        if unit.isFleet {
            types.append(.convoy)
        }
        return types
    }

    // MARK: - Unit Selection (Step 1)

    func selectUnit(_ unit: UnitDto) {
        // Don't allow changes after submission unless unlocked
        guard !isSubmitted else { return }

        selectedUnit = unit
        selectedOrderType = nil
        supportOrigin = nil
        currentOrder = nil
        showOrderPalette = true
    }

    func selectOrderType(_ type: OrderType) {
        selectedOrderType = type
        showOrderPalette = false

        if type == .hold {
            // Hold is immediate — no target needed
            let order = OrderDto(
                type: "HOLD",
                origin: selectedUnit?.territoryId
            )
            addOrder(order)
            resetEntry()
        }
    }

    // MARK: - Destination Selection (Step 2)

    func selectDestination(_ territoryId: String) {
        guard let unit = selectedUnit, let orderType = selectedOrderType else { return }

        switch orderType {
        case .move:
            let order = OrderDto(
                type: "MOVE",
                origin: unit.territoryId,
                destination: territoryId
            )
            addOrder(order)
            resetEntry()

        case .support:
            if supportOrigin == nil {
                // First tap: select the unit to support
                supportOrigin = territoryId
            } else {
                // Second tap: select where supported unit is going
                let order = OrderDto(
                    type: "SUPPORT",
                    origin: unit.territoryId,
                    supportTarget: SupportTargetDto(
                        origin: supportOrigin!,
                        destination: territoryId == supportOrigin! ? nil : territoryId
                    )
                )
                addOrder(order)
                resetEntry()
            }

        case .convoy:
            if supportOrigin == nil {
                supportOrigin = territoryId
            } else {
                let order = OrderDto(
                    type: "CONVOY",
                    origin: unit.territoryId,
                    convoyTarget: ConvoyTargetDto(
                        origin: supportOrigin!,
                        destination: territoryId
                    )
                )
                addOrder(order)
                resetEntry()
            }

        case .hold:
            break // Already handled
        }
    }

    // MARK: - Valid Destinations

    func validDestinations(units: [UnitDto]) -> Set<String> {
        guard let unit = selectedUnit, let orderType = selectedOrderType else { return [] }

        let adjacent = TerritoryData.adjacencies[unit.territoryId] ?? []

        switch orderType {
        case .move:
            return adjacent
        case .support:
            if supportOrigin == nil {
                // Show territories with friendly units
                let unitTerritories = Set(units.filter { $0.power == unit.power && $0.territoryId != unit.territoryId }.map(\.territoryId))
                return unitTerritories.intersection(adjacent.union([unit.territoryId]))
            } else {
                // Show where the supported unit can go
                return TerritoryData.adjacencies[supportOrigin!] ?? []
            }
        case .convoy:
            if supportOrigin == nil {
                // Show adjacent armies
                let armyTerritories = Set(units.filter { $0.isArmy }.map(\.territoryId))
                return armyTerritories
            } else {
                // Show possible convoy destinations
                return adjacent
            }
        case .hold:
            return []
        }
    }

    // MARK: - Order Management

    private func addOrder(_ order: OrderDto) {
        // Remove any existing order for same origin
        orders.removeAll { $0.origin == order.origin }
        orders.append(order)
        currentOrder = order
    }

    func removeOrder(at index: Int) {
        guard index < orders.count else { return }
        let removed = orders.remove(at: index)
        undoStack.append(removed)

        // Clear undo stack after 5 seconds
        let stackCount = undoStack.count
        Task {
            try? await Task.sleep(nanoseconds: 5_000_000_000)
            if undoStack.count == stackCount {
                undoStack.removeAll()
            }
        }
    }

    func removeOrder(for territoryId: String) {
        if let index = orders.firstIndex(where: { $0.origin == territoryId }) {
            removeOrder(at: index)
        }
    }

    func undoLastRemoval() {
        guard let last = undoStack.popLast() else { return }
        orders.append(last)
    }

    func clearAllOrders() {
        orders.removeAll()
        undoStack.removeAll()
        isSubmitted = false
    }

    func cancelOrder() {
        resetEntry()
    }

    private func resetEntry() {
        selectedUnit = nil
        selectedOrderType = nil
        supportOrigin = nil
        showOrderPalette = false
        currentOrder = nil
    }

    // MARK: - Submission

    func submitOrders() async {
        guard !isSubmitting else { return }

        // Check connectivity before submitting
        if !NetworkMonitor.shared.isConnected {
            submissionError = "You're offline. Your orders are saved locally and will be ready to submit when you reconnect."
            return
        }

        isSubmitting = true
        submissionError = nil

        do {
            let response = try await GameService.shared.submitOrders(gameId: gameId, orders: orders)
            validationResults = response.validationResults
            isSubmitted = response.submitted
        } catch let error as NetworkError {
            submissionError = error.errorDescription
        } catch {
            submissionError = "Failed to submit orders. Please try again."
        }

        isSubmitting = false
    }

    func unlockForResubmission() {
        isSubmitted = false
    }

    // MARK: - Plain Language

    func orderDescription(_ order: OrderDto) -> String {
        let origin = TerritoryData.territory(for: order.origin ?? "")?.name ?? order.origin ?? "?"

        switch order.type {
        case "HOLD":
            return "\(origin): Hold"
        case "MOVE":
            let dest = TerritoryData.territory(for: order.destination ?? "")?.name ?? order.destination ?? "?"
            return "\(origin) → \(dest)"
        case "SUPPORT":
            if let target = order.supportTarget {
                let supportOriginName = TerritoryData.territory(for: target.origin)?.name ?? target.origin
                if let dest = target.destination {
                    let destName = TerritoryData.territory(for: dest)?.name ?? dest
                    return "\(origin): Support \(supportOriginName) → \(destName)"
                } else {
                    return "\(origin): Support \(supportOriginName) hold"
                }
            }
            return "\(origin): Support"
        case "CONVOY":
            if let target = order.convoyTarget {
                let from = TerritoryData.territory(for: target.origin)?.name ?? target.origin
                let to = TerritoryData.territory(for: target.destination)?.name ?? target.destination
                return "\(origin): Convoy \(from) → \(to)"
            }
            return "\(origin): Convoy"
        default:
            return "\(origin): \(order.type)"
        }
    }
}
