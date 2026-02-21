import Foundation

// swiftlint:disable type_body_length file_length

enum MockData {

    // MARK: - Stable IDs

    static let playerId = UUID(uuidString: "00000000-0000-0000-0000-000000000001")!
    static let springOffensiveId = UUID(uuidString: "00000000-0000-0000-0000-000000000010")!
    static let medAllianceId = UUID(uuidString: "00000000-0000-0000-0000-000000000020")!
    static let easternFrontId = UUID(uuidString: "00000000-0000-0000-0000-000000000030")!

    static let francePlayerId = UUID(uuidString: "00000000-0000-0000-0000-000000000002")!
    static let germanyPlayerId = UUID(uuidString: "00000000-0000-0000-0000-000000000003")!
    static let italyPlayerId = UUID(uuidString: "00000000-0000-0000-0000-000000000004")!
    static let austriaPlayerId = UUID(uuidString: "00000000-0000-0000-0000-000000000005")!
    static let russiaPlayerId = UUID(uuidString: "00000000-0000-0000-0000-000000000006")!
    static let turkeyPlayerId = UUID(uuidString: "00000000-0000-0000-0000-000000000007")!

    static let convoBilateralFranceId = UUID(uuidString: "00000000-0000-0000-0000-000000000100")!
    static let convoBilateralGermanyId = UUID(uuidString: "00000000-0000-0000-0000-000000000200")!
    static let convoGlobalId = UUID(uuidString: "00000000-0000-0000-0000-000000000300")!

    // MARK: - Auth

    static let authResponse = AuthResponse(
        accessToken: "mock-access-token",
        refreshToken: "mock-refresh-token",
        player: PlayerSummary(
            id: playerId,
            displayName: "TestPlayer",
            elo: 1200,
            reliability: 0.95,
            rank: "INTERMEDIATE",
            createdAt: Date(timeIntervalSinceNow: -86400 * 90)
        )
    )

    // MARK: - Dashboard Games

    static let gameSummaries: [GameSummary] = [
        GameSummary(
            gameId: springOffensiveId,
            name: "Spring Offensive",
            status: "ACTIVE",
            power: "ENGLAND",
            currentPhase: "DIPLOMACY",
            currentSeason: "SPRING",
            currentYear: 1902,
            phaseDeadline: Date(timeIntervalSinceNow: 8 * 3600),
            ordersSubmitted: false,
            supplyCenterCount: 5,
            prevSupplyCenterCount: 4,
            unreadMessageCount: 2,
            playerCount: 7
        ),
        GameSummary(
            gameId: medAllianceId,
            name: "Mediterranean Alliance",
            status: "ACTIVE",
            power: "ITALY",
            currentPhase: "DIPLOMACY",
            currentSeason: "FALL",
            currentYear: 1903,
            phaseDeadline: Date(timeIntervalSinceNow: 16 * 3600),
            ordersSubmitted: true,
            supplyCenterCount: 4,
            prevSupplyCenterCount: 5,
            unreadMessageCount: 0,
            playerCount: 7
        ),
        GameSummary(
            gameId: easternFrontId,
            name: "Eastern Front",
            status: "ELIMINATED",
            power: "RUSSIA",
            currentPhase: "DIPLOMACY",
            currentSeason: "FALL",
            currentYear: 1905,
            phaseDeadline: nil,
            ordersSubmitted: false,
            supplyCenterCount: 0,
            prevSupplyCenterCount: 0,
            unreadMessageCount: 0,
            playerCount: 6
        )
    ]

    // MARK: - Game State (Spring Offensive)

    static let gameState: GameStateResponse = {
        let game = GameResponse(
            id: springOffensiveId,
            name: "Spring Offensive",
            status: "ACTIVE",
            creatorId: playerId,
            settings: GameSettings(
                map: "CLASSIC",
                phaseLength: "PT24H",
                pressRules: "FULL_PRESS",
                scoring: "DRAW_SIZE",
                minReliability: 70,
                ranked: true,
                readReceipts: false,
                anonymousCountries: false
            ),
            players: [
                GamePlayerSummary(playerId: playerId, power: "ENGLAND", ordersSubmitted: false, isEliminated: false, supplyCenterCount: 5),
                GamePlayerSummary(playerId: francePlayerId, power: "FRANCE", ordersSubmitted: true, isEliminated: false, supplyCenterCount: 5),
                GamePlayerSummary(playerId: germanyPlayerId, power: "GERMANY", ordersSubmitted: false, isEliminated: false, supplyCenterCount: 5),
                GamePlayerSummary(playerId: italyPlayerId, power: "ITALY", ordersSubmitted: true, isEliminated: false, supplyCenterCount: 4),
                GamePlayerSummary(playerId: austriaPlayerId, power: "AUSTRIA", ordersSubmitted: false, isEliminated: false, supplyCenterCount: 4),
                GamePlayerSummary(playerId: russiaPlayerId, power: "RUSSIA", ordersSubmitted: true, isEliminated: false, supplyCenterCount: 5),
                GamePlayerSummary(playerId: turkeyPlayerId, power: "TURKEY", ordersSubmitted: false, isEliminated: false, supplyCenterCount: 4)
            ],
            inviteCode: "SPRING22",
            currentPhase: "DIPLOMACY",
            currentSeason: "SPRING",
            currentYear: 1902,
            phaseDeadline: Date(timeIntervalSinceNow: 8 * 3600),
            createdAt: Date(timeIntervalSinceNow: -86400 * 14),
            startedAt: Date(timeIntervalSinceNow: -86400 * 12)
        )

        let units: [UnitDto] = [
            // England
            UnitDto(power: "ENGLAND", type: "FLEET", territoryId: "NTH"),
            UnitDto(power: "ENGLAND", type: "ARMY", territoryId: "BEL"),
            UnitDto(power: "ENGLAND", type: "FLEET", territoryId: "NWG"),
            // France
            UnitDto(power: "FRANCE", type: "ARMY", territoryId: "SPA"),
            UnitDto(power: "FRANCE", type: "FLEET", territoryId: "MAO"),
            UnitDto(power: "FRANCE", type: "ARMY", territoryId: "BUR"),
            // Germany
            UnitDto(power: "GERMANY", type: "ARMY", territoryId: "HOL"),
            UnitDto(power: "GERMANY", type: "ARMY", territoryId: "MUN"),
            UnitDto(power: "GERMANY", type: "FLEET", territoryId: "DEN"),
            // Italy
            UnitDto(power: "ITALY", type: "ARMY", territoryId: "VEN"),
            UnitDto(power: "ITALY", type: "ARMY", territoryId: "TUN"),
            UnitDto(power: "ITALY", type: "FLEET", territoryId: "ION"),
            // Austria
            UnitDto(power: "AUSTRIA", type: "ARMY", territoryId: "SER"),
            UnitDto(power: "AUSTRIA", type: "ARMY", territoryId: "BUD"),
            UnitDto(power: "AUSTRIA", type: "ARMY", territoryId: "VIE"),
            // Russia
            UnitDto(power: "RUSSIA", type: "ARMY", territoryId: "WAR"),
            UnitDto(power: "RUSSIA", type: "FLEET", territoryId: "SEV"),
            UnitDto(power: "RUSSIA", type: "ARMY", territoryId: "RUM"),
            UnitDto(power: "RUSSIA", type: "FLEET", territoryId: "BOT"),
            // Turkey
            UnitDto(power: "TURKEY", type: "ARMY", territoryId: "BUL"),
            UnitDto(power: "TURKEY", type: "FLEET", territoryId: "ANK"),
            UnitDto(power: "TURKEY", type: "ARMY", territoryId: "CON")
        ]

        let supplyCenters: [String: String?] = [
            // England (5)
            "LON": "ENGLAND", "EDI": "ENGLAND", "LVP": "ENGLAND",
            "NWY": "ENGLAND", "BEL": "ENGLAND",
            // France (5)
            "PAR": "FRANCE", "BRE": "FRANCE", "MAR": "FRANCE",
            "SPA": "FRANCE", "POR": "FRANCE",
            // Germany (5)
            "BER": "GERMANY", "KIE": "GERMANY", "MUN": "GERMANY",
            "HOL": "GERMANY", "DEN": "GERMANY",
            // Italy (4)
            "ROM": "ITALY", "NAP": "ITALY", "VEN": "ITALY",
            "TUN": "ITALY",
            // Austria (4)
            "VIE": "AUSTRIA", "BUD": "AUSTRIA", "TRI": "AUSTRIA",
            "SER": "AUSTRIA",
            // Russia (5)
            "MOS": "RUSSIA", "STP": "RUSSIA", "WAR": "RUSSIA",
            "SEV": "RUSSIA", "RUM": "RUSSIA",
            // Turkey (4)
            "ANK": "TURKEY", "CON": "TURKEY", "SMY": "TURKEY",
            "BUL": "TURKEY",
            // Neutral
            "SWE": nil, "GRE": nil
        ]

        return GameStateResponse(
            game: game,
            units: units,
            supplyCenters: supplyCenters,
            dislodgedUnits: nil
        )
    }()

    // MARK: - Order Submission

    static let orderSubmissionResponse = OrderSubmissionResponse(
        submitted: true,
        submittedAt: Date(),
        validationResults: [
            OrderValidationResult(order: "F NTH - NWY", status: "VALID", warning: nil, error: nil),
            OrderValidationResult(order: "A BEL - PIC", status: "VALID", warning: nil, error: nil),
            OrderValidationResult(order: "F NWG - BAR", status: "VALID", warning: nil, error: nil)
        ]
    )

    // MARK: - Conversations

    static func conversations(gameId: UUID) -> [ConversationSummary] {
        guard gameId == springOffensiveId else { return [] }
        return [
            ConversationSummary(
                id: convoBilateralFranceId,
                type: "BILATERAL",
                name: nil,
                participants: [
                    ConversationParticipant(playerId: playerId, power: "ENGLAND"),
                    ConversationParticipant(playerId: francePlayerId, power: "FRANCE")
                ],
                lastMessage: LastMessagePreview(
                    senderPower: "FRANCE",
                    preview: "I think we should coordinate on the Low Countries",
                    timestamp: Date(timeIntervalSinceNow: -1800),
                    isRead: false
                ),
                unreadCount: 2,
                muted: false,
                pinned: false
            ),
            ConversationSummary(
                id: convoBilateralGermanyId,
                type: "BILATERAL",
                name: nil,
                participants: [
                    ConversationParticipant(playerId: playerId, power: "ENGLAND"),
                    ConversationParticipant(playerId: germanyPlayerId, power: "GERMANY")
                ],
                lastMessage: LastMessagePreview(
                    senderPower: "ENGLAND",
                    preview: "Let's keep the peace in Scandinavia",
                    timestamp: Date(timeIntervalSinceNow: -7200),
                    isRead: true
                ),
                unreadCount: 0,
                muted: false,
                pinned: false
            ),
            ConversationSummary(
                id: convoGlobalId,
                type: "GLOBAL",
                name: "Global Chat",
                participants: Power.allCases.enumerated().map { index, power in
                    ConversationParticipant(
                        playerId: UUID(uuidString: "00000000-0000-0000-0000-00000000000\(index + 1)")!,
                        power: power.rawValue
                    )
                },
                lastMessage: LastMessagePreview(
                    senderPower: "TURKEY",
                    preview: "Good luck everyone!",
                    timestamp: Date(timeIntervalSinceNow: -86400),
                    isRead: true
                ),
                unreadCount: 0,
                muted: false,
                pinned: false
            )
        ]
    }

    // MARK: - Messages

    static func messages(conversationId: UUID) -> MessagePageResponse {
        switch conversationId {
        case convoBilateralFranceId:
            return franceBilateralMessages
        case convoBilateralGermanyId:
            return germanyBilateralMessages
        case convoGlobalId:
            return globalChatMessages
        default:
            return MessagePageResponse(messages: [], nextCursor: nil, hasMore: false)
        }
    }

    private static let franceBilateralMessages = MessagePageResponse(
        messages: [
            MessageResponse(
                id: UUID(), conversationId: convoBilateralFranceId,
                senderPlayerId: francePlayerId, senderPower: "FRANCE",
                type: "TEXT",
                content: "I think we should coordinate on the Low Countries",
                replyTo: nil, gamePhase: "SPRING 1902 DIPLOMACY",
                isSystem: false,
                createdAt: Date(timeIntervalSinceNow: -1800)
            ),
            MessageResponse(
                id: UUID(), conversationId: convoBilateralFranceId,
                senderPlayerId: francePlayerId, senderPower: "FRANCE",
                type: "TEXT",
                content: "Germany is getting too strong. Holland AND Denmark in one year.",
                replyTo: nil, gamePhase: "SPRING 1902 DIPLOMACY",
                isSystem: false,
                createdAt: Date(timeIntervalSinceNow: -2400)
            ),
            MessageResponse(
                id: UUID(), conversationId: convoBilateralFranceId,
                senderPlayerId: playerId, senderPower: "ENGLAND",
                type: "TEXT",
                content: "Agreed. I'll push into the North Sea to put pressure on Kiel.",
                replyTo: nil, gamePhase: "FALL 1901 DIPLOMACY",
                isSystem: false,
                createdAt: Date(timeIntervalSinceNow: -86400)
            ),
            MessageResponse(
                id: UUID(), conversationId: convoBilateralFranceId,
                senderPlayerId: francePlayerId, senderPower: "FRANCE",
                type: "TEXT",
                content: "Perfect. I'll move Burgundy to Munich if you cover Belgium.",
                replyTo: nil, gamePhase: "FALL 1901 DIPLOMACY",
                isSystem: false,
                createdAt: Date(timeIntervalSinceNow: -86400 + 600)
            ),
            MessageResponse(
                id: UUID(), conversationId: convoBilateralFranceId,
                senderPlayerId: playerId, senderPower: "ENGLAND",
                type: "TEXT",
                content: "Deal. Belgium is secure. What's your plan for Iberia?",
                replyTo: nil, gamePhase: "FALL 1901 DIPLOMACY",
                isSystem: false,
                createdAt: Date(timeIntervalSinceNow: -86400 + 1200)
            ),
            MessageResponse(
                id: UUID(), conversationId: convoBilateralFranceId,
                senderPlayerId: francePlayerId, senderPower: "FRANCE",
                type: "TEXT",
                content: "Taking Spain and Portugal, then pivoting north. No threat to you.",
                replyTo: nil, gamePhase: "SPRING 1901 DIPLOMACY",
                isSystem: false,
                createdAt: Date(timeIntervalSinceNow: -86400 * 3)
            ),
            MessageResponse(
                id: UUID(), conversationId: convoBilateralFranceId,
                senderPlayerId: playerId, senderPower: "ENGLAND",
                type: "TEXT",
                content: "Sounds good. Entente cordiale?",
                replyTo: nil, gamePhase: "SPRING 1901 DIPLOMACY",
                isSystem: false,
                createdAt: Date(timeIntervalSinceNow: -86400 * 3 + 300)
            )
        ],
        nextCursor: nil,
        hasMore: false
    )

    private static let germanyBilateralMessages = MessagePageResponse(
        messages: [
            MessageResponse(
                id: UUID(), conversationId: convoBilateralGermanyId,
                senderPlayerId: playerId, senderPower: "ENGLAND",
                type: "TEXT",
                content: "Let's keep the peace in Scandinavia",
                replyTo: nil, gamePhase: "SPRING 1902 DIPLOMACY",
                isSystem: false,
                createdAt: Date(timeIntervalSinceNow: -7200)
            ),
            MessageResponse(
                id: UUID(), conversationId: convoBilateralGermanyId,
                senderPlayerId: germanyPlayerId, senderPower: "GERMANY",
                type: "TEXT",
                content: "Agreed. I have no interest in Norway. Denmark is enough for me.",
                replyTo: nil, gamePhase: "SPRING 1902 DIPLOMACY",
                isSystem: false,
                createdAt: Date(timeIntervalSinceNow: -7200 + 300)
            ),
            MessageResponse(
                id: UUID(), conversationId: convoBilateralGermanyId,
                senderPlayerId: playerId, senderPower: "ENGLAND",
                type: "TEXT",
                content: "Good. I'll keep my fleet in the Norwegian Sea, purely defensive.",
                replyTo: nil, gamePhase: "SPRING 1902 DIPLOMACY",
                isSystem: false,
                createdAt: Date(timeIntervalSinceNow: -7200 + 600)
            ),
            MessageResponse(
                id: UUID(), conversationId: convoBilateralGermanyId,
                senderPlayerId: germanyPlayerId, senderPower: "GERMANY",
                type: "TEXT",
                content: "What do you think about the Russian situation? They're expanding fast.",
                replyTo: nil, gamePhase: "FALL 1901 DIPLOMACY",
                isSystem: false,
                createdAt: Date(timeIntervalSinceNow: -86400 * 2)
            ),
            MessageResponse(
                id: UUID(), conversationId: convoBilateralGermanyId,
                senderPlayerId: playerId, senderPower: "ENGLAND",
                type: "TEXT",
                content: "Concerning. Four supply centers already. We may need to act together.",
                replyTo: nil, gamePhase: "FALL 1901 DIPLOMACY",
                isSystem: false,
                createdAt: Date(timeIntervalSinceNow: -86400 * 2 + 600)
            )
        ],
        nextCursor: nil,
        hasMore: false
    )

    private static let globalChatMessages = MessagePageResponse(
        messages: [
            MessageResponse(
                id: UUID(), conversationId: convoGlobalId,
                senderPlayerId: turkeyPlayerId, senderPower: "TURKEY",
                type: "TEXT",
                content: "Good luck everyone!",
                replyTo: nil, gamePhase: "SPRING 1901 DIPLOMACY",
                isSystem: false,
                createdAt: Date(timeIntervalSinceNow: -86400)
            ),
            MessageResponse(
                id: UUID(), conversationId: convoGlobalId,
                senderPlayerId: italyPlayerId, senderPower: "ITALY",
                type: "TEXT",
                content: "May the best diplomat win.",
                replyTo: nil, gamePhase: "SPRING 1901 DIPLOMACY",
                isSystem: false,
                createdAt: Date(timeIntervalSinceNow: -86400 + 120)
            ),
            MessageResponse(
                id: UUID(), conversationId: convoGlobalId,
                senderPlayerId: russiaPlayerId, senderPower: "RUSSIA",
                type: "TEXT",
                content: "Proposing a peaceful first year. Any takers?",
                replyTo: nil, gamePhase: "SPRING 1901 DIPLOMACY",
                isSystem: false,
                createdAt: Date(timeIntervalSinceNow: -86400 + 300)
            ),
            MessageResponse(
                id: UUID(), conversationId: convoGlobalId,
                senderPlayerId: austriaPlayerId, senderPower: "AUSTRIA",
                type: "TEXT",
                content: "Ha! In Diplomacy? Good one.",
                replyTo: nil, gamePhase: "SPRING 1901 DIPLOMACY",
                isSystem: false,
                createdAt: Date(timeIntervalSinceNow: -86400 + 600)
            ),
            MessageResponse(
                id: UUID(), conversationId: convoGlobalId,
                senderPlayerId: playerId, senderPower: "ENGLAND",
                type: "TEXT",
                content: "Just here to keep the seas safe. Nothing to worry about.",
                replyTo: nil, gamePhase: "SPRING 1901 DIPLOMACY",
                isSystem: false,
                createdAt: Date(timeIntervalSinceNow: -86400 + 900)
            )
        ],
        nextCursor: nil,
        hasMore: false
    )

    // MARK: - Send Message Helper

    static func sentMessage(conversationId: UUID, content: String) -> MessageResponse {
        MessageResponse(
            id: UUID(),
            conversationId: conversationId,
            senderPlayerId: playerId,
            senderPower: "ENGLAND",
            type: "TEXT",
            content: content,
            replyTo: nil,
            gamePhase: "SPRING 1902 DIPLOMACY",
            isSystem: false,
            createdAt: Date()
        )
    }
}

// swiftlint:enable type_body_length file_length
