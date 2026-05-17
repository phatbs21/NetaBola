package vn._lab.netabola.api_gateway.route;
import org.springframework.cloud.gateway.route.RouteLocator;
import org.springframework.cloud.gateway.route.builder.RouteLocatorBuilder;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
@Configuration
public class CartRoute {
    @Bean
    public RouteLocator cartRoutes(RouteLocatorBuilder builder) {
        return builder.routes()
            .route("cart", r -> r.path("/api/carts/**").filters(f -> f.stripPrefix(2))
                .uri("lb://cart-service")).build();
    }
}
