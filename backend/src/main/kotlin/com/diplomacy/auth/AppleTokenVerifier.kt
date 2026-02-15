package com.diplomacy.auth

import com.fasterxml.jackson.databind.ObjectMapper
import org.springframework.stereotype.Component
import org.springframework.web.reactive.function.client.WebClient
import reactor.core.publisher.Mono
import java.math.BigInteger
import java.security.KeyFactory
import java.security.interfaces.RSAPublicKey
import java.security.spec.RSAPublicKeySpec
import java.util.Base64

@Component
class AppleTokenVerifier(private val objectMapper: ObjectMapper) {

    private val webClient = WebClient.create("https://appleid.apple.com")

    data class AppleJwk(val kty: String, val kid: String, val use: String, val alg: String, val n: String, val e: String)
    data class AppleJwks(val keys: List<AppleJwk>)
    data class AppleTokenPayload(val sub: String, val email: String?, val email_verified: String?)

    fun verify(idToken: String): Mono<AppleTokenPayload> {
        val parts = idToken.split(".")
        if (parts.size != 3) return Mono.error(IllegalArgumentException("Invalid token format"))

        val header = objectMapper.readTree(Base64.getUrlDecoder().decode(parts[0]))
        val kid = header["kid"]?.asText() ?: return Mono.error(IllegalArgumentException("Missing kid"))
        val alg = header["alg"]?.asText() ?: return Mono.error(IllegalArgumentException("Missing alg"))

        return webClient.get()
            .uri("/auth/keys")
            .retrieve()
            .bodyToMono(AppleJwks::class.java)
            .flatMap { jwks ->
                val matchingKey = jwks.keys.find { it.kid == kid && it.alg == alg }
                    ?: return@flatMap Mono.error<AppleTokenPayload>(IllegalArgumentException("No matching key"))

                val publicKey = buildRsaPublicKey(matchingKey.n, matchingKey.e)

                val payload = try {
                    io.jsonwebtoken.Jwts.parser()
                        .verifyWith(publicKey)
                        .requireIssuer("https://appleid.apple.com")
                        .build()
                        .parseSignedClaims(idToken)
                        .payload
                } catch (e: Exception) {
                    return@flatMap Mono.error<AppleTokenPayload>(IllegalArgumentException("Invalid Apple token"))
                }

                Mono.just(
                    AppleTokenPayload(
                        sub = payload.subject,
                        email = payload["email"] as? String,
                        email_verified = payload["email_verified"]?.toString()
                    )
                )
            }
    }

    private fun buildRsaPublicKey(n: String, e: String): RSAPublicKey {
        val decoder = Base64.getUrlDecoder()
        val modulus = BigInteger(1, decoder.decode(n))
        val exponent = BigInteger(1, decoder.decode(e))
        val spec = RSAPublicKeySpec(modulus, exponent)
        return KeyFactory.getInstance("RSA").generatePublic(spec) as RSAPublicKey
    }
}
