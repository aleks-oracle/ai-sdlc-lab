package io.github.aleksai.ledger.app;

import static org.assertj.core.api.Assertions.assertThat;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.context.ApplicationContext;

/**
 * Smoke test: the Spring application context starts. Fails if the configuration is broken.
 *
 * <p>Infrastructure test, not linked to a requirement ID (no spec exists in Stage 1).
 */
@SpringBootTest
class LedgerApplicationTest {

    @Autowired
    private ApplicationContext context;

    @Test
    void contextLoads() {
        assertThat(context).isNotNull();
        assertThat(context.getBeansOfType(LedgerApplication.class)).hasSize(1);
    }
}
