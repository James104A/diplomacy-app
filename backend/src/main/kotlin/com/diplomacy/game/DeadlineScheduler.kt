package com.diplomacy.game

import com.diplomacy.notification.NotificationService
import org.slf4j.LoggerFactory
import org.springframework.scheduling.annotation.Scheduled
import org.springframework.stereotype.Component
import java.time.Instant

/**
 * E4-S5: Deadline scheduler.
 * Polls every 30 seconds for games with expired deadlines or all orders submitted,
 * and triggers adjudication. Also triggers deadline reminder notifications (E6-S2).
 */
@Component
class DeadlineScheduler(
    private val gameRepository: GameRepository,
    private val adjudicationOrchestrator: AdjudicationOrchestrator,
    private val notificationService: NotificationService
) {
    private val log = LoggerFactory.getLogger(DeadlineScheduler::class.java)

    @Scheduled(fixedRate = 30_000) // every 30 seconds
    fun checkDeadlines() {
        val now = Instant.now()

        // Find games past deadline
        gameRepository.findByStatusAndPhaseDeadlineBefore("IN_PROGRESS", now)
            .flatMap { game ->
                log.info("Deadline expired for game ${game.id}, triggering adjudication")
                adjudicationOrchestrator.runAdjudication(game.id!!)
            }
            .subscribe(
                { log.info("Adjudication completed for game ${it.id}") },
                { log.error("Adjudication failed", it) }
            )

        // Find games with all orders submitted (early adjudication - E4-S6)
        gameRepository.findByStatusAndPhaseDeadlineBefore("IN_PROGRESS", Instant.MAX)
            .filter { it.allOrdersSubmitted }
            .flatMap { game ->
                log.info("All orders submitted for game ${game.id}, triggering early adjudication")
                adjudicationOrchestrator.runAdjudication(game.id!!)
            }
            .subscribe(
                { log.info("Early adjudication completed for game ${it.id}") },
                { log.error("Early adjudication failed", it) }
            )

        // E6-S2: Check deadline reminders for active games
        gameRepository.findByStatusAndPhaseDeadlineBefore("IN_PROGRESS", Instant.MAX)
            .filter { it.phaseDeadline != null && it.phaseDeadline.isAfter(now) }
            .flatMap { game ->
                notificationService.checkDeadlineReminders(game.id!!, game.name, game.phaseDeadline!!)
            }
            .subscribe(
                {},
                { log.error("Deadline reminder check failed", it) }
            )
    }
}
