package vn._lab.netabola.api_gateway.route;
import org.springframework.cloud.gateway.route.RouteLocator;
import org.springframework.cloud.gateway.route.builder.RouteLocatorBuilder;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
@Configuration
public class OrderRoute {
    @Bean
    public RouteLocator orderRoutes(RouteLocatorBuilder builder) {
        return builder.routes()
            .route("order", r -> r.path("/api/orders/**", "/api/checkout/**")
                .filters(f -> f.stripPrefix(2).addRequestHeader("X-User-Id", "X-User-Id"))
                .uri("lb://order-service")).build();
    }
}
