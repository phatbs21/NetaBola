package vn._lab.netabola.order_service.repository;
import org.springframework.data.jpa.repository.JpaRepository;
import vn._lab.netabola.order_service.model.Order;
import java.util.List; import java.util.Optional; import java.util.UUID;
public interface OrderRepository extends JpaRepository<Order, UUID> {
    List<Order> findByUserIdOrderByCreatedAtDesc(java.util.UUID userId);
    Optional<Order> findByStripePaymentId(String stripePaymentId);
}
