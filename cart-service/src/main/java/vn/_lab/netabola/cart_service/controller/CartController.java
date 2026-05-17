package vn._lab.netabola.cart_service.controller;
import lombok.RequiredArgsConstructor; import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import vn._lab.netabola.cart_service.service.CartService;
@RestController @RequestMapping("/api/carts") @RequiredArgsConstructor
public class CartController {
    private final CartService cartService;
    @GetMapping("/current") public ResponseEntity<?> getCurrentCart(@RequestHeader("X-User-Id") String userId) {
        return ResponseEntity.ok(cartService.getOrCreateCart(java.util.UUID.fromString(userId)));
    }
}
