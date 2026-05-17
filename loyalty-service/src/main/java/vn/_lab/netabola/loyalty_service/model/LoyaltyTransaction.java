package vn._lab.netabola.loyalty_service.model;
import jakarta.persistence.*; import lombok.*; import java.math.BigDecimal; import java.time.Instant;
import java.util.UUID;
@Entity @Table(name = "loyalty_transactions") @Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class LoyaltyTransaction {
    @Id @GeneratedValue(strategy = GenerationType.UUID) private UUID id;
    @Column(name = "user_id", nullable = false) private UUID userId;
    @Enumerated(EnumType.STRING) @Column(nullable = false) private TransactionType type;
    @Column(nullable = false) private Integer points;
    @Column(name = "order_id") private UUID orderId;
    @Column(length = 500) private String description;
    @Column(name = "created_at") private Instant createdAt;
}
enum TransactionType { EARNED, REDEEMED, EXPIRED }
