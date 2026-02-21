import SwiftUI
import Combine

struct ConversationView: View {
    let conversationId: UUID
    let title: String
    let myPower: String
    let palette: PowerPalette

    @StateObject private var viewModel: ConversationViewModel

    init(conversationId: UUID, title: String, myPower: String, palette: PowerPalette) {
        self.conversationId = conversationId
        self.title = title
        self.myPower = myPower
        self.palette = palette
        _viewModel = StateObject(wrappedValue: ConversationViewModel(
            conversationId: conversationId,
            myPower: myPower
        ))
    }

    var body: some View {
        VStack(spacing: 0) {
            OfflineBanner()

            // Messages
            messagesList

            // Composer
            MessageComposerView(
                text: $viewModel.composerText,
                isSending: viewModel.isSending,
                onSend: {
                    Task { await viewModel.sendMessage() }
                }
            )
        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await viewModel.loadMessages()
            viewModel.subscribeToWebSocket()
            await viewModel.markAsRead()
        }
        .onDisappear {
            Task { await viewModel.markAsRead() }
        }
    }

    private var messagesList: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: Spacing.xxs) {
                    // Load more button
                    if viewModel.hasMore {
                        Button("Load earlier messages") {
                            Task { await viewModel.loadMore() }
                        }
                        .font(.appCaption)
                        .foregroundColor(.appPrimary)
                        .padding(.vertical, Spacing.sm)
                    }

                    ForEach(viewModel.groupedMessages, id: \.phase) { group in
                        // Phase divider
                        if let phase = group.phase {
                            PhaseDivider(phase: phase)
                        }

                        ForEach(group.messages) { message in
                            MessageBubble(
                                message: message,
                                isMe: message.senderPower == myPower,
                                palette: palette
                            )
                            .id(message.id)
                        }
                    }

                    // Pending messages
                    ForEach(viewModel.pendingMessages) { pending in
                        PendingMessageBubble(
                            text: pending.content,
                            failed: pending.failed,
                            onRetry: {
                                Task { await viewModel.retryMessage(pending) }
                            },
                            onDelete: {
                                viewModel.removePendingMessage(pending)
                            }
                        )
                        .id(pending.id)
                    }
                }
                .padding(.horizontal, Spacing.sm)
                .padding(.vertical, Spacing.xs)
            }
            .onChange(of: viewModel.scrollToBottom) { _ in
                if let lastId = viewModel.lastMessageId {
                    withAnimation(.easeOut(duration: 0.2)) {
                        proxy.scrollTo(lastId, anchor: .bottom)
                    }
                }
            }
            .onAppear {
                if let lastId = viewModel.lastMessageId {
                    proxy.scrollTo(lastId, anchor: .bottom)
                }
            }
        }
    }
}

// MARK: - Conversation ViewModel

@MainActor
class ConversationViewModel: ObservableObject {
    let conversationId: UUID
    let myPower: String

    @Published var messages: [MessageResponse] = []
    @Published var pendingMessages: [PendingMessage] = []
    @Published var composerText = ""
    @Published var isSending = false
    @Published var isLoading = true
    @Published var hasMore = false
    @Published var scrollToBottom = UUID()

    private var nextCursor: String?
    private var cancellable: AnyCancellable?
    private var isAtBottom = true

    struct PendingMessage: Identifiable {
        let id = UUID()
        let content: String
        let sentAt = Date()
        var failed = false
    }

    var lastMessageId: UUID? {
        pendingMessages.last?.id ?? messages.last?.id
    }

    var groupedMessages: [MessageGroup] {
        var groups: [MessageGroup] = []
        var currentPhase: String?
        var currentMessages: [MessageResponse] = []

        for message in messages {
            let phase = message.gamePhase
            if phase != currentPhase {
                if !currentMessages.isEmpty {
                    groups.append(MessageGroup(phase: currentPhase, messages: currentMessages))
                }
                currentPhase = phase
                currentMessages = [message]
            } else {
                currentMessages.append(message)
            }
        }
        if !currentMessages.isEmpty {
            groups.append(MessageGroup(phase: currentPhase, messages: currentMessages))
        }

        return groups
    }

    init(conversationId: UUID, myPower: String) {
        self.conversationId = conversationId
        self.myPower = myPower
    }

    func loadMessages() async {
        isLoading = messages.isEmpty

        do {
            let response = try await MessagingService.shared.getMessages(conversationId: conversationId)
            messages = response.messages.reversed() // API returns newest first
            hasMore = response.hasMore
            nextCursor = response.nextCursor
            scrollToBottom = UUID()
        } catch {
            // Silent fail — messages list stays empty
        }
        isLoading = false
    }

    func loadMore() async {
        guard let cursor = nextCursor else { return }

        do {
            let response = try await MessagingService.shared.getMessages(
                conversationId: conversationId,
                cursor: cursor
            )
            let older = response.messages.reversed()
            messages.insert(contentsOf: older, at: 0)
            hasMore = response.hasMore
            nextCursor = response.nextCursor
        } catch {
            // Silent fail
        }
    }

    func sendMessage() async {
        let text = composerText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty, !isSending else { return }

        composerText = ""
        let pending = PendingMessage(content: text)
        pendingMessages.append(pending)
        scrollToBottom = UUID()

        isSending = true
        do {
            let message = try await MessagingService.shared.sendMessage(
                conversationId: conversationId,
                content: text
            )
            // Replace pending with real message
            pendingMessages.removeAll { $0.id == pending.id }
            messages.append(message)
            scrollToBottom = UUID()
        } catch {
            // Mark as failed so user can retry
            if let index = pendingMessages.firstIndex(where: { $0.id == pending.id }) {
                pendingMessages[index].failed = true
            }
        }
        isSending = false
    }

    func markAsRead() async {
        guard let lastId = messages.last?.id else { return }
        try? await MessagingService.shared.markRead(
            conversationId: conversationId,
            lastMessageId: lastId
        )
    }

    func retryMessage(_ pending: PendingMessage) async {
        guard pending.failed else { return }

        // Reset failed state
        if let index = pendingMessages.firstIndex(where: { $0.id == pending.id }) {
            pendingMessages[index].failed = false
        }

        isSending = true
        do {
            let message = try await MessagingService.shared.sendMessage(
                conversationId: conversationId,
                content: pending.content
            )
            pendingMessages.removeAll { $0.id == pending.id }
            messages.append(message)
            scrollToBottom = UUID()
        } catch {
            if let index = pendingMessages.firstIndex(where: { $0.id == pending.id }) {
                pendingMessages[index].failed = true
            }
        }
        isSending = false
    }

    func removePendingMessage(_ pending: PendingMessage) {
        pendingMessages.removeAll { $0.id == pending.id }
    }

    func subscribeToWebSocket() {
        cancellable = WebSocketManager.shared.eventPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] event in
                guard let self else { return }
                if event.event == "message.new",
                   let data = event.data,
                   let convIdStr = data["conversationId"] as? String,
                   let convId = UUID(uuidString: convIdStr),
                   convId == self.conversationId {
                    Task { await self.loadMessages() }
                }
            }
    }
}

struct MessageGroup: Identifiable {
    let phase: String?
    let messages: [MessageResponse]
    var id: String { phase ?? "no-phase" }
}

// MARK: - Phase Divider

struct PhaseDivider: View {
    let phase: String

    var body: some View {
        HStack {
            Rectangle()
                .fill(Color.appSecondary.opacity(0.2))
                .frame(height: 1)
            Text(phase)
                .font(.appCaption)
                .foregroundColor(.appSecondary)
                .lineLimit(1)
            Rectangle()
                .fill(Color.appSecondary.opacity(0.2))
                .frame(height: 1)
        }
        .padding(.vertical, Spacing.xs)
    }
}

// MARK: - Message Bubble

struct MessageBubble: View {
    let message: MessageResponse
    let isMe: Bool
    let palette: PowerPalette

    @State private var showAbsoluteTime = false

    var body: some View {
        HStack {
            if isMe { Spacer(minLength: 60) }

            VStack(alignment: isMe ? .trailing : .leading, spacing: 2) {
                // Sender label (for opponent messages)
                if !isMe, let power = message.senderPowerEnum {
                    HStack(spacing: Spacing.xxs) {
                        Circle()
                            .fill(power.color(palette: palette))
                            .frame(width: 8, height: 8)
                        Text(power.displayName)
                            .font(.appCaption)
                            .foregroundColor(.appSecondary)
                    }
                }

                // Bubble
                Text(message.content)
                    .font(.appSecondary)
                    .foregroundColor(isMe ? .white : .primary)
                    .padding(.horizontal, Spacing.sm)
                    .padding(.vertical, Spacing.xs)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(isMe ? Color.appPrimary : Color.appGroupedBackground)
                    )

                // Timestamp
                Text(showAbsoluteTime ? absoluteTime : relativeTime)
                    .font(.system(size: 10))
                    .foregroundColor(.appSecondary.opacity(0.6))
                    .onTapGesture { showAbsoluteTime.toggle() }
            }

            if !isMe { Spacer(minLength: 60) }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(bubbleAccessibilityLabel)
    }

    private var bubbleAccessibilityLabel: String {
        let sender = isMe ? "You" : (message.senderPowerEnum?.displayName ?? message.senderPower)
        return "\(sender): \(message.content), \(relativeTime)"
    }

    private var relativeTime: String {
        let interval = Date().timeIntervalSince(message.createdAt)
        if interval < 60 { return "now" }
        if interval < 3600 { return "\(Int(interval / 60))m ago" }
        if interval < 86400 { return "\(Int(interval / 3600))h ago" }
        return "\(Int(interval / 86400))d ago"
    }

    private var absoluteTime: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: message.createdAt)
    }
}

// MARK: - Pending Message Bubble

struct PendingMessageBubble: View {
    let text: String
    let failed: Bool
    var onRetry: (() -> Void)?
    var onDelete: (() -> Void)?

    var body: some View {
        HStack {
            Spacer(minLength: 60)

            VStack(alignment: .trailing, spacing: 2) {
                Text(text)
                    .font(.appSecondary)
                    .foregroundColor(.white.opacity(failed ? 0.6 : 0.8))
                    .padding(.horizontal, Spacing.sm)
                    .padding(.vertical, Spacing.xs)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(failed ? Color.appError.opacity(0.6) : Color.appPrimary.opacity(0.6))
                    )

                if failed {
                    HStack(spacing: Spacing.xs) {
                        Image(systemName: "exclamationmark.circle")
                            .font(.system(size: 9))
                            .foregroundColor(.appError)
                        Text("Failed")
                            .font(.system(size: 10))
                            .foregroundColor(.appError)
                        Button("Retry") {
                            onRetry?()
                        }
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.appPrimary)
                        Button("Delete") {
                            onDelete?()
                        }
                        .font(.system(size: 10))
                        .foregroundColor(.appSecondary)
                    }
                } else {
                    HStack(spacing: 2) {
                        Image(systemName: "clock")
                            .font(.system(size: 9))
                        Text("Sending...")
                            .font(.system(size: 10))
                    }
                    .foregroundColor(.appSecondary.opacity(0.5))
                }
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(failed ? "Failed to send: \(text). Double tap to retry." : "Sending: \(text)")
    }
}

// MARK: - Message Composer

struct MessageComposerView: View {
    @Binding var text: String
    let isSending: Bool
    let onSend: () -> Void

    var body: some View {
        HStack(spacing: Spacing.xs) {
            TextField("Type a message...", text: $text, axis: .vertical)
                .font(.appSecondary)
                .lineLimit(1...5)
                .padding(.horizontal, Spacing.sm)
                .padding(.vertical, Spacing.xs)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.appGroupedBackground)
                )
                .submitLabel(.send)
                .onSubmit {
                    if !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        onSend()
                    }
                }

            Button {
                onSend()
            } label: {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.system(size: 32))
                    .foregroundColor(canSend ? .appPrimary : .appSecondary.opacity(0.3))
            }
            .disabled(!canSend)
            .accessibilityLabel("Send message")
        }
        .padding(.horizontal, Spacing.sm)
        .padding(.vertical, Spacing.xs)
        .background(.ultraThinMaterial)
    }

    private var canSend: Bool {
        !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !isSending
    }
}
