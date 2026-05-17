package vn._lab.netabola.auth_service.controller;
import jakarta.validation.Valid; import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity; import org.springframework.web.bind.annotation.*;
import vn._lab.netabola.auth_service.dto.*;
import vn._lab.netabola.auth_service.service.AuthService;
@RestController @RequestMapping("/api/auth") @RequiredArgsConstructor
public class AuthController {
    private final AuthService authService;
    @PostMapping("/register") public ResponseEntity<AuthResponse> register(@Valid @RequestBody RegisterRequest req) {
        return ResponseEntity.ok(authService.register(req));
    }
    @PostMapping("/login") public ResponseEntity<AuthResponse> login(@Valid @RequestBody LoginRequest req) {
        return ResponseEntity.ok(authService.login(req));
    }
    @PostMapping("/refresh") public ResponseEntity<AuthResponse> refresh(@RequestHeader("Authorization") String auth) {
        return ResponseEntity.ok(authService.refreshToken(auth.replace("Bearer ", "")));
    }
    @PostMapping("/logout") public ResponseEntity<Void> logout(@RequestHeader("Authorization") String auth) {
        authService.logout(auth.replace("Bearer ", "")); return ResponseEntity.ok().build();
    }
}
