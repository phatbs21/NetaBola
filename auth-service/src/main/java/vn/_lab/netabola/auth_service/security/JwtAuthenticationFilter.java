package vn._lab.netabola.auth_service.security;
import jakarta.servlet.FilterChain; import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest; import jakarta.servlet.http.HttpServletResponse;
import lombok.extern.slf4j.Slf4j; import org.springframework.web.filter.OncePerRequestFilter;
import java.io.IOException;
@Slf4j
public class JwtAuthenticationFilter extends OncePerRequestFilter {
    private final JwtService jwtService;
    public JwtAuthenticationFilter(JwtService jwtService) { this.jwtService = jwtService; }
    @Override protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response, FilterChain chain)
            throws ServletException, IOException {
        String header = request.getHeader("Authorization");
        if (header != null && header.startsWith("Bearer ")) {
            String token = header.substring(7);
            if (jwtService.validateToken(token)) {
                log.debug("JWT valid for request: {}", request.getRequestURI());
            } else {
                log.warn("JWT validation failed for: {}", request.getRequestURI());
            }
        }
        chain.doFilter(request, response);
    }
}
