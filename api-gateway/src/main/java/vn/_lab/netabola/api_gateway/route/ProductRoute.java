package vn._lab.netabola.api_gateway.route;
import org.springframework.cloud.gateway.route.RouteLocator;
import org.springframework.cloud.gateway.route.builder.RouteLocatorBuilder;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
@Configuration
public class ProductRoute {
    @Bean
    public RouteLocator productRoutes(RouteLocatorBuilder builder) {
        return builder.routes()
            .route("product", r -> r.path("/api/products/**").filters(f -> f.stripPrefix(2))
                .uri("lb://product-service")).build();
    }
}
