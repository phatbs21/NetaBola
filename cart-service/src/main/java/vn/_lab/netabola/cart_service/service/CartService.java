package vn._lab.netabola.cart_service.service;
import lombok.RequiredArgsConstructor; import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import vn._lab.netabola.cart_service.model.Cart;
import vn._lab.netabola.cart_service.repository.CartRepository;
import java.time.Instant; import java.util.UUID;
@Service @RequiredArgsConstructor @Slf4j
public class CartService {
    private final CartRepository cartRepository;
    public Cart getOrCreateCart(UUID userId) {
        return cartRepository.findByUserIdAndActiveTrue(userId).orElseGet(() -> {
            Cart cart = Cart.builder().userId(userId).createdAt(Instant.now()).build();
            return cartRepository.save(cart);
        });
    }
    public Cart findCartById(UUID cartId) {
        return cartRepository.findById(cartId).orElseThrow(() -> new RuntimeException("Cart not found"));
    }
}
