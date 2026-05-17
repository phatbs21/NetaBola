package vn._lab.netabola.auth_service.security;
import org.springframework.context.annotation.Bean; import org.springframework.context.annotation.Configuration;
@Configuration
public class RsaKeyPairConfig {
    @Bean public RsaKeyPair rsaKeyPair() { return RsaKeyPair.loadOrGenerate(); }
}
