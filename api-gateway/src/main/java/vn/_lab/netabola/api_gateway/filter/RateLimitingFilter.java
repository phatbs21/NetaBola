package vn._lab.netabola.api_gateway.filter;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.cloud.gateway.filter.GatewayFilterChain;
import org.springframework.cloud.gateway.filter.GlobalFilter;
import org.springframework.core.Ordered;
import org.springframework.data.redis.core.ReactiveStringReactiveHashOperations;
import org.springframework.data.redis.core.ReactiveHashOperations;
import org.springframework.data.redis.core.ReactiveRedisTemplate;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Component;
import lombok.extern.slf4j.Slf4j;
import reactor.core.publisher.Mono;
import java.time.Duration;
import java.time.Instant;
@Component
@Slf4j
public class RateLimitingFilter implements GlobalFilter, Ordered {
    private final ReactiveRedisTemplate<String, String> redisTemplate;
    @Value("${rate-limit.capacity:100}") private int capacity;
    @Override
    public int getOrder() { return -2; }
    @Override
    public Mono<Void> filter(org.springframework.cloud.gateway.server.mvc.filter.ServerWebExchangeExchange exchange, GatewayFilterChain chain) {
        String clientIp = exchange.getRequest().getRemoteAddress() != null
            ? exchange.getRequest().getRemoteAddress().getAddress().getHostAddress() : "unknown";
        String key = "rate-limit:" + clientIp;
        Instant now = Instant.now();
        return redisTemplate.opsForValue().increment(key).flatMap(count -> {
            if (count == 1) {
                redisTemplate.expire(key, Duration.ofMinutes(1));
            }
            if (count > capacity) {
                log.warn("Rate limit exceeded for IP: {} (count: {})", clientIp, count);
                exchange.getResponse().setStatusCode(HttpStatus.TOO_MANY_REQUESTS);
                return exchange.getResponse().writeWith(Mono.just(exchange.getResponse().bufferFactory().wrap(
                    ("{\"error\":\"Rate limit exceeded\"}").getBytes())));
            }
            return chain.filter(exchange);
        });
    }
}
