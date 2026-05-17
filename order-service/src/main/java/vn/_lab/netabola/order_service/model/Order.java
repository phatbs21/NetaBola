package vn._lab.netabola.order_service.model;
import jakarta.persistence.*; import lombok.*; import java.math.BigDecimal; import java.time.Instant;
@Entity @Table(name = "orders") @Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class Order {
    @Id @GeneratedValue(strategy = GenerationType.UUID) private java.util.UUID id;
    @Column(name = "user_id", nullable = false) private java.util.UUID userId;
    @Column(name = "cart_id") private java.util.UUID cartId;
    @Enumerated(EnumType.STRING) @Column(nullable = false) private OrderStatus status;
    @Column(nullable = false, precision = 12, scale = 2) private BigDecimal totalAmount;
    @Column(name = "stripe_payment_id") private String stripePaymentId;
    @Column(length = 1000) private String shippingAddress;
    @Column(length = 500) private String cancelledReason;
    @Column(name = "created_at") private Instant createdAt;
    @Column(name = "updated_at") private Instant updatedAt;
    @Column(name = "paid_at") private Instant paidAt;
    @Column(name = "cancelled_at") private Instant cancelledAt;
}
enum OrderStatus { PENDING, CONFIRMED, PAID, PROCESSING, SHIPPED, DELIVERED, CANCELLED, EXPIRED }
