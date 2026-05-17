package vn._lab.netabola.api_gateway.route;
import org.springframework.cloud.gateway.route.RouteLocator;
import org.springframework.cloud.gateway.route.builder.RouteLocatorBuilder;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
@Configuration
public class LoyaltyRoute {
    @Bean
    public RouteLocator loyaltyRoutes(RouteLocatorBuilder builder) {
        return builder.routes()
            .route("loyalty", r -> r.path("/api/loyalty/**")
                .filters(f -> f.stripPrefix(2))
                .uri("lb://loyalty-service")).build();
    }
}
