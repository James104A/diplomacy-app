package com.diplomacy.auth

import io.jsonwebtoken.Claims
import io.jsonwebtoken.JwtException
import io.jsonwebtoken.Jwts
import io.jsonwebtoken.security.Keys
import org.springframework.stereotype.Service
import java.util.Date
import java.util.UUID
import javax.crypto.SecretKey

@Service
class JwtService(private val jwtProperties: JwtProperties) {

    private val key: SecretKey by lazy {
        Keys.hmacShaKeyFor(jwtProperties.secret.toByteArray())
    }

    fun generateAccessToken(playerId: UUID): String {
        val now = Date()
        val expiry = Date(now.time + jwtProperties.accessTokenExpiration * 1000)
        return Jwts.builder()
            .subject(playerId.toString())
            .claim("type", "access")
            .issuedAt(now)
            .expiration(expiry)
            .signWith(key)
            .compact()
    }

    fun generateRefreshToken(playerId: UUID): String {
        val now = Date()
        val expiry = Date(now.time + jwtProperties.refreshTokenExpiration * 1000)
        return Jwts.builder()
            .subject(playerId.toString())
            .claim("type", "refresh")
            .id(UUID.randomUUID().toString())
            .issuedAt(now)
            .expiration(expiry)
            .signWith(key)
            .compact()
    }

    fun validateToken(token: String): Claims? {
        return try {
            Jwts.parser()
                .verifyWith(key)
                .build()
                .parseSignedClaims(token)
                .payload
        } catch (e: JwtException) {
            null
        } catch (e: IllegalArgumentException) {
            null
        }
    }

    fun getPlayerIdFromToken(token: String): UUID? {
        return validateToken(token)?.subject?.let { UUID.fromString(it) }
    }
}
