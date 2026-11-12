package io.github.aleks_oracle.ledger.app;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

/**
 * Entry point of the ledger service.
 *
 * <p>{@code @SpringBootApplication} turns on component scanning (for this package and below) and
 * auto-configuration. Stage 1 has no beans yet; REST and persistence come in Stage 2.
 */
@SpringBootApplication
public class LedgerApplication {

    public static void main(String[] args) {
        SpringApplication.run(LedgerApplication.class, args);
    }
}
