package vn._lab.netabola.api_gateway.filter;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.io.buffer.DataBuffer;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Component;
import org.springframework.web.server.ServerWebExchange;
import com.fasterxml.jackson.databind.ObjectMapper;
import io.jsonwebtoken.*;
import io.jsonwebtoken.security.Keys;
import lombok.extern.slf4j.Slf4j;
import reactor.core.publisher.Mono;
import javax.crypto.SecretKey;
import java.nio.charset.StandardCharsets;
@Component
@Slf4j
public class JwtAuthFilter implements org.springframework.web.server.WebFilter {
    private final SecretKey signingKey;
    private final ObjectMapper objectMapper = new ObjectMapper();
    public JwtAuthFilter(@Value("${jwt.secret-key}") String secretKey) {
        this.signingKey = Keys.hmacShaKeyFor(secretKey.getBytes(StandardCharsets.UTF_8));
    }
    @Override
    public Mono<Void> filter(ServerWebExchange exchange, org.springframework.web.server.WebFilterChain chain) {
        String path = exchange.getRequest().getURI().getPath();
        if (path.startsWith("/api/auth") || path.startsWith("/.well-known")) {
            return chain.filter(exchange);
        }
        String authHeader = exchange.getRequest().getHeaders().getFirst(HttpHeaders.AUTHORIZATION);
        if (authHeader == null || !authHeader.startsWith("Bearer ")) {
            return sendError(exchange, "Missing authorization header", HttpStatus.UNAUTHORIZED);
        }
        String token = authHeader.substring(7);
        try {
            Claims claims = Jwts.parser().verifyWith(signingKey).build().parseSignedClaims(token).getPayload();
            String userId = claims.getSubject();
            String role = claims.get("role", String.class);
            exchange.mutate().request(exchange.getRequest().mutate()
                .header("X-User-Id", userId)
                .header("X-User-Role", role).build()).build();
            log.debug("JWT valid for user: {}", userId);
            return chain.filter(exchange);
        } catch (Exception e) {
            log.warn("JWT validation failed: {}", e.getMessage());
            return sendError(exchange, "Invalid token", HttpStatus.UNAUTHORIZED);
        }
    }
    private Mono<Void> sendError(ServerWebExchange exchange, String msg, HttpStatus status) {
        exchange.getResponse().setStatusCode(status);
        exchange.getResponse().getHeaders().setContentType(org.springframework.http.MediaType.APPLICATION_JSON);
        var body = objectMapper.writeValueAsString(new ErrorResp(msg));
        DataBuffer buffer = exchange.getResponse().writeWith(
            org.springframework.core.io.buffer.DataBufferUtils.buffer(body.getBytes(StandardCharsets.UTF_8)));
        return buffer;
    }
    record ErrorResp(String message) {}
}
