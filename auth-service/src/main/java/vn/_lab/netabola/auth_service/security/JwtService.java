package vn._lab.netabola.auth_service.security;
import io.jsonwebtoken.*; import io.jsonwebtoken.security.Keys;
import org.springframework.beans.factory.annotation.Value; import org.springframework.stereotype.Service;
import vn._lab.netabola.auth_service.model.User;
import javax.crypto.SecretKey; import java.nio.charset.StandardCharsets; import java.util.Date;
@Service
public class JwtService {
    private final SecretKey signingKey; private final long expirationMs; private final long refreshExpirationMs;
    public JwtService(@Value("${jwt.secret-key}") String secretKey,
                      @Value("${jwt.expiration-ms}") long expirationMs,
                      @Value("${jwt.refresh-expiration-ms}") long refreshExpirationMs) {
        this.signingKey = Keys.hmacShaKeyFor(secretKey.getBytes(StandardCharsets.UTF_8));
        this.expirationMs = expirationMs; this.refreshExpirationMs = refreshExpirationMs;
    }
    public String generateToken(User user) {
        return Jwts.builder().subject(user.getId().toString())
            .claim("email", user.getEmail()).claim("role", user.getRole().name())
            .issuedAt(Date.from(java.time.Instant.now()))
            .expiration(Date.from(java.time.Instant.now().plusMillis(expirationMs)))
            .signWith(signingKey).compact();
    }
    public String generateRefreshToken(User user) {
        return Jwts.builder().subject(user.getId().toString()).claim("type", "refresh")
            .issuedAt(Date.from(java.time.Instant.now()))
            .expiration(Date.from(java.time.Instant.now().plusMillis(refreshExpirationMs)))
            .signWith(signingKey).compact();
    }
    public Claims parseToken(String token) {
        return Jwts.parser().verifyWith(signingKey).build().parseSignedClaims(token).getPayload();
    }
    public boolean validateToken(String token) {
        try { parseToken(token); return true; }
        catch (JwtException | IllegalArgumentException e) { return false; }
    }
}
