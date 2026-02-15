package com.diplomacy.auth

import org.springframework.boot.context.properties.ConfigurationProperties

@ConfigurationProperties(prefix = "app.jwt")
data class JwtProperties(
    val secret: String = "change-me-in-production-this-must-be-at-least-256-bits-long-for-hs256",
    val accessTokenExpiration: Long = 900,      // 15 minutes in seconds
    val refreshTokenExpiration: Long = 2592000  // 30 days in seconds
)
