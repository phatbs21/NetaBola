package vn._lab.netabola.loyalty_service.repository;
import org.springframework.data.jpa.repository.JpaRepository;
import vn._lab.netabola.loyalty_service.model.LoyaltyPoint;
import java.util.Optional; import java.util.UUID;
public interface LoyaltyPointRepository extends JpaRepository<LoyaltyPoint, UUID> {
    Optional<LoyaltyPoint> findByUserId(UUID userId);
}
