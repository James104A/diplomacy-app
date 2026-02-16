import SwiftUI
import Combine

struct MessagingHubView: View {
    let gameId: UUID
    let myPower: String
    let palette: PowerPalette

    @State private var conversations: [ConversationSummary] = []
    @State private var isLoading = true
    @State private var errorMessage: String?
    @State private var selectedConversation: ConversationSummary?
    @State private var cancellable: AnyCancellable?

    var body: some View {
        Group {
            if isLoading {
                ProgressView("Loading conversations...")
            } else if let error = errorMessage, conversations.isEmpty {
                VStack(spacing: Spacing.md) {
                    Image(systemName: "bubble.left.and.bubble.right")
                        .font(.system(size: 48))
                        .foregroundColor(.appSecondary.opacity(0.5))
                    Text(error)
                        .font(.appSecondary)
                        .foregroundColor(.appSecondary)
                }
            } else {
                conversationList
            }
        }
        .navigationTitle("Messages")
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(item: $selectedConversation) { conversation in
            ConversationView(
                conversationId: conversation.id,
                title: conversation.displayName,
                myPower: myPower,
                palette: palette
            )
        }
        .task {
            await loadConversations()
            subscribeToUpdates()
        }
        .onDisappear {
            cancellable?.cancel()
        }
    }

    private var conversationList: some View {
        List {
            ForEach(sortedConversations) { conversation in
                Button {
                    selectedConversation = conversation
                } label: {
                    ConversationRow(conversation: conversation, palette: palette)
                }
                .buttonStyle(.plain)
            }
        }
        .listStyle(.plain)
        .refreshable {
            await loadConversations()
        }
    }

    private var sortedConversations: [ConversationSummary] {
        conversations.sorted { a, b in
            if a.unreadCount > 0 && b.unreadCount == 0 { return true }
            if a.unreadCount == 0 && b.unreadCount > 0 { return false }
            let aDate = a.lastMessage?.timestamp ?? .distantPast
            let bDate = b.lastMessage?.timestamp ?? .distantPast
            return aDate > bDate
        }
    }

    private func loadConversations() async {
        isLoading = conversations.isEmpty
        errorMessage = nil

        do {
            conversations = try await MessagingService.shared.getConversations(gameId: gameId)
        } catch let error as NetworkError {
            errorMessage = error.errorDescription
        } catch {
            errorMessage = "Failed to load conversations."
        }
        isLoading = false
    }

    private func subscribeToUpdates() {
        cancellable = WebSocketManager.shared.eventPublisher
            .receive(on: DispatchQueue.main)
            .sink { event in
                if event.event == "message.new" && event.gameId == gameId.uuidString {
                    Task { await loadConversations() }
                }
            }
    }
}

// MARK: - Conversation Row

struct ConversationRow: View {
    let conversation: ConversationSummary
    let palette: PowerPalette

    var body: some View {
        HStack(spacing: Spacing.sm) {
            // Power color indicator
            powerIndicator

            VStack(alignment: .leading, spacing: Spacing.xxs) {
                // Top: name + timestamp
                HStack {
                    Text(conversation.displayName)
                        .font(conversation.unreadCount > 0 ? .appSecondaryBold : .appSecondary)
                        .foregroundColor(.primary)
                        .lineLimit(1)

                    Spacer()

                    if let lastMessage = conversation.lastMessage {
                        Text(relativeTime(lastMessage.timestamp))
                            .font(.appCaption)
                            .foregroundColor(.appSecondary)
                    }
                }

                // Bottom: preview + badge
                HStack {
                    if let lastMessage = conversation.lastMessage {
                        Text(lastMessage.preview)
                            .font(.appCaption)
                            .foregroundColor(.appSecondary)
                            .lineLimit(1)
                    } else {
                        Text("No messages yet")
                            .font(.appCaption)
                            .foregroundColor(.appSecondary.opacity(0.5))
                            .italic()
                    }

                    Spacer()

                    if conversation.unreadCount > 0 {
                        BadgeView(count: conversation.unreadCount)
                    }
                }
            }
        }
        .padding(.vertical, Spacing.xxs)
    }

    @ViewBuilder
    private var powerIndicator: some View {
        if conversation.type == "GLOBAL" {
            Image(systemName: "globe")
                .foregroundColor(.appPrimary)
                .frame(width: 32, height: 32)
        } else if let participant = conversation.participants.first,
                  let power = participant.powerEnum {
            Circle()
                .fill(power.color(palette: palette))
                .frame(width: 32, height: 32)
                .overlay(
                    Text(String(power.displayName.prefix(1)))
                        .font(.appBadge)
                        .foregroundColor(.white)
                )
        } else {
            Circle()
                .fill(Color.appSecondary.opacity(0.3))
                .frame(width: 32, height: 32)
        }
    }

    private func relativeTime(_ date: Date) -> String {
        let interval = Date().timeIntervalSince(date)
        if interval < 60 { return "now" }
        if interval < 3600 { return "\(Int(interval / 60))m" }
        if interval < 86400 { return "\(Int(interval / 3600))h" }
        if interval < 604800 { return "\(Int(interval / 86400))d" }
        return "\(Int(interval / 604800))w"
    }
}

// MARK: - Hashable conformance for navigation

extension ConversationSummary: Hashable {
    static func == (lhs: ConversationSummary, rhs: ConversationSummary) -> Bool {
        lhs.id == rhs.id
    }
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
