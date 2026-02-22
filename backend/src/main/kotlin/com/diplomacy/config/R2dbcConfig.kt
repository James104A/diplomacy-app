package com.diplomacy.config

import org.springframework.context.annotation.Bean
import org.springframework.context.annotation.Configuration
import org.springframework.data.relational.core.mapping.NamingStrategy
import org.springframework.data.relational.core.mapping.RelationalPersistentProperty

@Configuration
class R2dbcConfig {
    @Bean
    fun namingStrategy() = object : NamingStrategy {
        override fun getColumnName(property: RelationalPersistentProperty): String {
            return property.name.replace(Regex("([a-z0-9])([A-Z])"), "$1_$2").lowercase()
        }
    }
}
