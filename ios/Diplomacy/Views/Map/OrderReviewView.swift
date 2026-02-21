import SwiftUI

struct OrderReviewView: View {
    @ObservedObject var viewModel: OrderEntryViewModel
    let palette: PowerPalette
    @Environment(\.dismiss) private var dismiss

    @State private var showClearConfirmation = false
    @State private var showUnlockConfirmation = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Orders list
                if viewModel.orders.isEmpty {
                    emptyView
                } else {
                    ordersList
                }

                // Undo toast
                if !viewModel.undoStack.isEmpty {
                    undoToast
                }

                // Validation results
                if !viewModel.validationResults.isEmpty {
                    validationSection
                }

                // Bottom actions
                bottomActions
            }
            .navigationTitle("Order Review")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") { dismiss() }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    if !viewModel.orders.isEmpty && !viewModel.isSubmitted {
                        Button("Clear All") {
                            showClearConfirmation = true
                        }
                        .foregroundColor(.appError)
                    }
                }
            }
            .alert("Clear All Orders?", isPresented: $showClearConfirmation) {
                Button("Clear All", role: .destructive) {
                    viewModel.clearAllOrders()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This will remove all orders. This cannot be undone.")
            }
            .alert("Resubmit Orders?", isPresented: $showUnlockConfirmation) {
                Button("Unlock", role: .destructive) {
                    viewModel.unlockForResubmission()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This will unlock your orders for editing. You'll need to submit again.")
            }
        }
    }

    // MARK: - Orders List

    private var ordersList: some View {
        List {
            // Missing orders warning
            let missingCount = missingOrderCount
            if missingCount > 0 && !viewModel.isSubmitted {
                HStack(spacing: Spacing.xs) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.appWarning)
                    Text("\(missingCount) unit\(missingCount == 1 ? "" : "s") without orders")
                        .font(.appSecondary)
                        .foregroundColor(.appWarning)
                }
                .listRowBackground(Color.appWarning.opacity(0.1))
            }

            ForEach(Array(viewModel.orders.enumerated()), id: \.element.id) { index, order in
                orderRow(order, at: index)
            }
            .onDelete { indexSet in
                for index in indexSet {
                    viewModel.removeOrder(at: index)
                }
            }
            .deleteDisabled(viewModel.isSubmitted)
        }
        .listStyle(.insetGrouped)
    }

    private func orderRow(_ order: OrderDto, at index: Int) -> some View {
        HStack(spacing: Spacing.sm) {
            // Order type icon
            orderIcon(for: order)

            // Description
            VStack(alignment: .leading, spacing: 2) {
                Text(viewModel.orderDescription(order))
                    .font(.appSecondary)

                // Validation result
                if let result = validationResult(for: order) {
                    HStack(spacing: Spacing.xxs) {
                        Image(systemName: validationIcon(result.status))
                            .font(.appCaption)
                            .foregroundColor(validationColor(result.status))
                        Text(result.warning ?? result.error ?? result.status)
                            .font(.appCaption)
                            .foregroundColor(validationColor(result.status))
                    }
                }
            }

            Spacer()

            // Submitted indicator
            if viewModel.isSubmitted {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.appSuccess)
            }
        }
        .opacity(viewModel.isSubmitted ? 0.7 : 1.0)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(orderAccessibilityLabel(order))
    }

    private func orderAccessibilityLabel(_ order: OrderDto) -> String {
        var label = viewModel.orderDescription(order)
        if viewModel.isSubmitted {
            label += ", submitted"
        }
        if let result = validationResult(for: order) {
            if let error = result.error {
                label += ", invalid: \(error)"
            } else if let warning = result.warning {
                label += ", warning: \(warning)"
            } else if result.status == "VALID" {
                label += ", valid"
            }
        }
        return label
    }

    private func orderIcon(for order: OrderDto) -> some View {
        let icon: String
        let color: Color
        switch order.type {
        case "HOLD":
            icon = "shield"
            color = .appSecondary
        case "MOVE":
            icon = "arrow.right"
            color = .appPrimary
        case "SUPPORT":
            icon = "person.2"
            color = .appSuccess
        case "CONVOY":
            icon = "water.waves"
            color = .appWarning
        default:
            icon = "questionmark"
            color = .appSecondary
        }

        return Image(systemName: icon)
            .foregroundColor(color)
            .frame(width: 24)
    }

    // MARK: - Empty State

    private var emptyView: some View {
        VStack(spacing: Spacing.md) {
            Spacer()
            Image(systemName: "doc.text")
                .font(.system(size: 48))
                .foregroundColor(.appSecondary.opacity(0.5))
            Text("No Orders Yet")
                .font(.appSectionHeader)
            Text("Tap units on the map to enter orders")
                .font(.appSecondary)
                .foregroundColor(.appSecondary)
            Spacer()
        }
    }

    // MARK: - Undo Toast

    private var undoToast: some View {
        HStack {
            Text("Order removed")
                .font(.appSecondary)
            Spacer()
            Button("Undo") {
                viewModel.undoLastRemoval()
            }
            .font(.appSecondaryBold)
            .foregroundColor(.appPrimary)
        }
        .padding(Spacing.sm)
        .background(Color.appGroupedBackground)
        .cornerRadius(Spacing.xs)
        .padding(.horizontal, Spacing.md)
        .transition(.move(edge: .bottom).combined(with: .opacity))
    }

    // MARK: - Validation Section

    private var validationSection: some View {
        let errors = viewModel.validationResults.filter { $0.status == "INVALID" }
        let warnings = viewModel.validationResults.filter { $0.status == "WARNING" }

        return Group {
            if !errors.isEmpty || !warnings.isEmpty {
                VStack(alignment: .leading, spacing: Spacing.xs) {
                    ForEach(errors) { result in
                        HStack(spacing: Spacing.xxs) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.appError)
                            Text(result.error ?? result.order)
                                .font(.appCaption)
                                .foregroundColor(.appError)
                        }
                    }
                    ForEach(warnings) { result in
                        HStack(spacing: Spacing.xxs) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.appWarning)
                            Text(result.warning ?? result.order)
                                .font(.appCaption)
                                .foregroundColor(.appWarning)
                        }
                    }
                }
                .padding(Spacing.sm)
                .background(Color.appGroupedBackground)
                .cornerRadius(Spacing.xs)
                .padding(.horizontal, Spacing.md)
            }
        }
    }

    // MARK: - Bottom Actions

    private var bottomActions: some View {
        VStack(spacing: Spacing.sm) {
            if let error = viewModel.submissionError {
                Text(error)
                    .font(.appCaption)
                    .foregroundColor(.appError)
            }

            if viewModel.isSubmitted {
                HStack(spacing: Spacing.sm) {
                    Image(systemName: "checkmark.seal.fill")
                        .foregroundColor(.appSuccess)
                    Text("Orders Submitted")
                        .font(.appSecondaryBold)
                        .foregroundColor(.appSuccess)
                    Spacer()
                    Button("Edit") {
                        showUnlockConfirmation = true
                    }
                    .font(.appSecondaryBold)
                    .foregroundColor(.appPrimary)
                }
                .padding(Spacing.sm)
            } else {
                DiplomacyButton(
                    title: viewModel.isSubmitting ? "Submitting..." : "Submit Orders",
                    style: viewModel.orders.isEmpty ? .disabled : .primary
                ) {
                    Task { await viewModel.submitOrders() }
                }
                .disabled(viewModel.isSubmitting)
            }
        }
        .padding(Spacing.md)
        .background(.ultraThinMaterial)
    }

    // MARK: - Helpers

    private var missingOrderCount: Int {
        // This would need actual unit count from game state
        // For now, approximate based on order count
        max(0, 3 - viewModel.orders.count)
    }

    private func validationResult(for order: OrderDto) -> OrderValidationResult? {
        viewModel.validationResults.first { $0.order.contains(order.origin ?? "") }
    }

    private func validationIcon(_ status: String) -> String {
        switch status {
        case "VALID": return "checkmark.circle"
        case "WARNING": return "exclamationmark.triangle"
        case "INVALID": return "xmark.circle"
        default: return "questionmark.circle"
        }
    }

    private func validationColor(_ status: String) -> Color {
        switch status {
        case "VALID": return .appSuccess
        case "WARNING": return .appWarning
        case "INVALID": return .appError
        default: return .appSecondary
        }
    }
}
