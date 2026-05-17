package vn._lab.netabola.auth_service.security;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping; import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController; import java.util.Map;
@RestController @RequestMapping("/.well-known")
public class JwkService {
    private final RsaKeyPair rsaKeyPair;
    @Autowired public JwkService(RsaKeyPair rsaKeyPair) { this.rsaKeyPair = rsaKeyPair; }
    @GetMapping("/jwks.json") public Map<String, Object> getJwks() {
        return Map.of("keys", Map.of("kty", "RSA"));
    }
}
