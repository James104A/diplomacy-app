import Foundation
import Combine

// MARK: - WebSocket Event

struct WebSocketEvent: Decodable {
    let event: String
    let seq: Int?
    let gameId: String?
    let timestamp: String?
    let data: [String: AnyCodable]?
}

// MARK: - WebSocket Manager

@MainActor
class WebSocketManager: ObservableObject {
    static let shared = WebSocketManager()

    @Published var isConnected = false

    private var webSocketTask: URLSessionWebSocketTask?
    private var session: URLSession
    private var lastSeq: Int = 0
    private var retryCount = 0
    private var heartbeatTimer: Timer?
    private var pongTimer: Timer?
    private var isManuallyDisconnected = false

    private let eventSubject = PassthroughSubject<WebSocketEvent, Never>()
    var eventPublisher: AnyPublisher<WebSocketEvent, Never> {
        eventSubject.eraseToAnyPublisher()
    }

    private static let maxRetryDelay: TimeInterval = 30
    private static let heartbeatInterval: TimeInterval = 30
    private static let pongTimeout: TimeInterval = 10
    private static let wsBaseURL = "wss://ws.diplomacy.app/v1/events"

    private init() {
        self.session = URLSession(configuration: .default)
    }

    // MARK: - Connection Lifecycle

    func connect() {
        guard !isConnected else { return }
        isManuallyDisconnected = false

        guard let token = KeychainManager.load(key: .accessToken) else {
            print("[WS] No access token, cannot connect")
            return
        }

        var urlString = "\(Self.wsBaseURL)?token=\(token)"
        if lastSeq > 0 {
            urlString += "&lastSeq=\(lastSeq)"
        }

        guard let url = URL(string: urlString) else { return }

        webSocketTask = session.webSocketTask(with: url)
        webSocketTask?.resume()

        isConnected = true
        retryCount = 0
        startHeartbeat()
        receiveMessage()

        print("[WS] Connected (lastSeq: \(lastSeq))")
    }

    func disconnect() {
        isManuallyDisconnected = true
        tearDown()
    }

    private func tearDown() {
        heartbeatTimer?.invalidate()
        heartbeatTimer = nil
        pongTimer?.invalidate()
        pongTimer = nil
        webSocketTask?.cancel(with: .normalClosure, reason: nil)
        webSocketTask = nil
        isConnected = false
    }

    // MARK: - Receive Loop

    private func receiveMessage() {
        webSocketTask?.receive { [weak self] result in
            Task { @MainActor in
                guard let self = self else { return }

                switch result {
                case .success(let message):
                    self.handleMessage(message)
                    self.receiveMessage() // Continue listening

                case .failure(let error):
                    print("[WS] Receive error: \(error.localizedDescription)")
                    self.handleDisconnect()
                }
            }
        }
    }

    private func handleMessage(_ message: URLSessionWebSocketTask.Message) {
        switch message {
        case .string(let text):
            if text == "pong" {
                pongTimer?.invalidate()
                pongTimer = nil
                return
            }

            guard let data = text.data(using: .utf8) else { return }
            do {
                let event = try JSONDecoder().decode(WebSocketEvent.self, from: data)
                if let seq = event.seq {
                    lastSeq = max(lastSeq, seq)
                }
                eventSubject.send(event)
            } catch {
                print("[WS] Decode error: \(error)")
            }

        case .data:
            break // Binary frames not used

        @unknown default:
            break
        }
    }

    // MARK: - Heartbeat

    private func startHeartbeat() {
        heartbeatTimer?.invalidate()
        heartbeatTimer = Timer.scheduledTimer(withTimeInterval: Self.heartbeatInterval, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.sendPing()
            }
        }
    }

    private func sendPing() {
        webSocketTask?.send(.string("ping")) { [weak self] error in
            if let error = error {
                print("[WS] Ping send error: \(error)")
                Task { @MainActor in
                    self?.handleDisconnect()
                }
                return
            }
        }

        // Start pong timeout
        pongTimer?.invalidate()
        pongTimer = Timer.scheduledTimer(withTimeInterval: Self.pongTimeout, repeats: false) { [weak self] _ in
            Task { @MainActor in
                print("[WS] Pong timeout, reconnecting...")
                self?.handleDisconnect()
            }
        }
    }

    // MARK: - Reconnection with Exponential Backoff

    private func handleDisconnect() {
        tearDown()

        guard !isManuallyDisconnected else { return }

        let delay = min(pow(2.0, Double(retryCount)), Self.maxRetryDelay)
        retryCount += 1

        print("[WS] Reconnecting in \(delay)s (attempt \(retryCount))")

        Task {
            try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
            connect()
        }
    }
}

// MARK: - AnyCodable for flexible JSON values

struct AnyCodable: Codable {
    let value: Any

    init(_ value: Any) {
        self.value = value
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let string = try? container.decode(String.self) {
            value = string
        } else if let int = try? container.decode(Int.self) {
            value = int
        } else if let double = try? container.decode(Double.self) {
            value = double
        } else if let bool = try? container.decode(Bool.self) {
            value = bool
        } else if let dict = try? container.decode([String: AnyCodable].self) {
            value = dict.mapValues { $0.value }
        } else if let array = try? container.decode([AnyCodable].self) {
            value = array.map { $0.value }
        } else {
            value = NSNull()
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        if let string = value as? String {
            try container.encode(string)
        } else if let int = value as? Int {
            try container.encode(int)
        } else if let double = value as? Double {
            try container.encode(double)
        } else if let bool = value as? Bool {
            try container.encode(bool)
        } else {
            try container.encodeNil()
        }
    }
}
