package vn._lab.netabola.loyalty_service.repository;
import org.springframework.data.jpa.repository.JpaRepository;
import vn._lab.netabola.loyalty_service.model.LoyaltyTransaction;
import java.util.List; import java.util.UUID;
public interface LoyaltyTransactionRepository extends JpaRepository<LoyaltyTransaction, UUID> {
    List<LoyaltyTransaction> findByUserIdOrderByCreatedAtDesc(UUID userId);
}
