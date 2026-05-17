package vn._lab.netabola.loyalty_service.model;
import jakarta.persistence.*; import lombok.*; import java.math.BigDecimal; import java.time.Instant;
@Entity @Table(name = "loyalty_points") @Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class LoyaltyPoint {
    @Id @GeneratedValue(strategy = GenerationType.UUID) private java.util.UUID id;
    @Column(name = "user_id", nullable = false) private java.util.UUID userId;
    @Column(name = "order_id") private java.util.UUID orderId;
    @Column(nullable = false) private Integer pointsEarned;
    @Column(nullable = false) private Integer pointsUsed;
    @Column(nullable = false) private Integer balance;
    @Column(name = "created_at") private Instant createdAt;
}
