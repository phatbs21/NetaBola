package vn._lab.netabola.auth_service.service;
import lombok.RequiredArgsConstructor; import lombok.extern.slf4j.Slf4j;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service; import org.springframework.transaction.annotation.Transactional;
import vn._lab.netabola.auth_service.dto.*;
import vn._lab.netabola.auth_service.model.*;
import vn._lab.netabola.auth_service.repository.RefreshTokenRepository;
import vn._lab.netabola.auth_service.repository.UserRepository;
import vn._lab.netabola.auth_service.security.JwtService;
import java.time.Instant; import java.util.UUID;
@Service @RequiredArgsConstructor @Slf4j
public class AuthService {
    private final UserRepository userRepository;
    private final RefreshTokenRepository refreshTokenRepository;
    private final JwtService jwtService;
    private final PasswordEncoder passwordEncoder;
    @Transactional
    public AuthResponse register(RegisterRequest req) {
        if (userRepository.existsByEmail(req.getEmail())) {
            log.warn("Email exists: {}", req.getEmail()); throw new RuntimeException("Email already exists");
        }
        User user = User.builder().email(req.getEmail())
            .password(passwordEncoder.encode(req.getPassword())).username(req.getUsername())
            .role(Role.USER).enabled(true).createdAt(Instant.now()).build();
        user = userRepository.save(user);
        log.info("Registered: {}", user.getEmail());
        return AuthResponse.builder().accessToken(jwtService.generateToken(user))
            .refreshToken(jwtService.generateRefreshToken(user)).tokenType("Bearer")
            .expiresIn(3600).user(UserResponse.from(user)).build();
    }
    public AuthResponse login(LoginRequest req) {
        User user = userRepository.findByEmail(req.getEmail()).orElseThrow(() -> {
            log.warn("Login failed: {}", req.getEmail()); return new RuntimeException("Invalid credentials");
        });
        if (!passwordEncoder.matches(req.getPassword(), user.getPassword())) {
            log.warn("Wrong password: {}", req.getEmail()); throw new RuntimeException("Invalid credentials");
        }
        log.info("Login success: {}", user.getEmail());
        return AuthResponse.builder().accessToken(jwtService.generateToken(user))
            .refreshToken(jwtService.generateRefreshToken(user)).tokenType("Bearer")
            .expiresIn(3600).user(UserResponse.from(user)).build();
    }
    public AuthResponse refreshToken(String refreshToken) {
        if (!jwtService.validateToken(refreshToken)) {
            log.warn("Invalid refresh token"); throw new RuntimeException("Invalid refresh token");
        }
        var claims = jwtService.parseToken(refreshToken);
        UUID userId = UUID.fromString(claims.getSubject());
        RefreshToken token = refreshTokenRepository.findByToken(refreshToken).orElseThrow(() -> {
            log.warn("Refresh token not found"); return new RuntimeException("Refresh token not found");
        });
        if (token.isExpired()) { log.warn("Expired token"); throw new RuntimeException("Refresh token expired"); }
        User user = userRepository.findById(userId).orElseThrow(() -> new RuntimeException("User not found"));
        String newRefresh = jwtService.generateRefreshToken(user);
        refreshTokenRepository.delete(token);
        log.info("Token refreshed for: {}", userId);
        return AuthResponse.builder().accessToken(jwtService.generateToken(user))
            .refreshToken(newRefresh).tokenType("Bearer").expiresIn(3600)
            .user(UserResponse.from(user)).build();
    }
    @Transactional
    public void logout(String refreshToken) {
        RefreshToken token = refreshTokenRepository.findByToken(refreshToken).orElseThrow();
        refreshTokenRepository.delete(token);
        log.info("User logged out");
    }
}
