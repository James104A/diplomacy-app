package com.diplomacy.notification

import jakarta.validation.Valid
import org.springframework.http.HttpStatus
import org.springframework.security.core.annotation.AuthenticationPrincipal
import org.springframework.web.bind.annotation.*
import reactor.core.publisher.Mono
import java.util.UUID

@RestController
@RequestMapping("/v1/players/me")
class NotificationController(private val notificationService: NotificationService) {

    // E6-S1: Register device token
    @PostMapping("/devices")
    @ResponseStatus(HttpStatus.CREATED)
    fun registerDevice(
        @AuthenticationPrincipal playerId: UUID,
        @Valid @RequestBody request: RegisterDeviceRequest
    ): Mono<DeviceResponse> {
        return notificationService.registerDevice(playerId, request)
    }

    // E6-S1: Deactivate device
    @DeleteMapping("/devices/{deviceId}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    fun deactivateDevice(
        @AuthenticationPrincipal playerId: UUID,
        @PathVariable deviceId: String
    ): Mono<Void> {
        return notificationService.deactivateDevice(playerId, deviceId)
    }

    // E6-S3: Get notification preferences
    @GetMapping("/notifications")
    fun getPreferences(
        @AuthenticationPrincipal playerId: UUID
    ): Mono<NotificationPreferencesDto> {
        return notificationService.getPreferences(playerId)
    }

    // E6-S3: Update notification preferences
    @PutMapping("/notifications")
    fun updatePreferences(
        @AuthenticationPrincipal playerId: UUID,
        @Valid @RequestBody prefs: NotificationPreferencesDto
    ): Mono<NotificationPreferencesDto> {
        return notificationService.updatePreferences(playerId, prefs)
    }
}
