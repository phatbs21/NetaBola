package vn._lab.netabola.cart_service.repository;
import org.springframework.data.jpa.repository.JpaRepository;
import vn._lab.netabola.cart_service.model.Cart;
import java.util.Optional; import java.util.UUID;
public interface CartRepository extends JpaRepository<Cart, UUID> {
    Optional<Cart> findByUserIdAndActiveTrue(java.util.UUID userId);
}
