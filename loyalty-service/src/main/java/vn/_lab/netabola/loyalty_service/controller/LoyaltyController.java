package vn._lab.netabola.loyalty_service.controller;
import lombok.RequiredArgsConstructor; import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import vn._lab.netabola.loyalty_service.service.LoyaltyService;
@RestController @RequestMapping("/api/loyalty") @RequiredArgsConstructor
public class LoyaltyController {
    private final LoyaltyService loyaltyService;
    @GetMapping("/points") public ResponseEntity<?> getPoints(@RequestHeader("X-User-Id") String userId) {
        return ResponseEntity.ok(loyaltyService);
    }
}
