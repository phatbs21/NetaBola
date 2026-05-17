package vn._lab.netabola.api_gateway.config;
import org.springframework.boot.web.error.ErrorAttributeOptions;
import org.springframework.boot.web.reactive.error.ErrorAttributes;
import org.springframework.stereotype.Component;
import java.util.Map;
@Component
public class CustomErrorAttributes implements ErrorAttributes {
    @Override
    public Map<String, Object> getErrorAttributes(ErrorAttributeOptions options) {
        return Map.of("timestamp", java.time.Instant.now().toString(),
            "status", 500, "error", "Internal Server Error");
    }
    @Override
    public Throwable getError(ErrorAttributeOptions options) {
        return null;
    }
}
