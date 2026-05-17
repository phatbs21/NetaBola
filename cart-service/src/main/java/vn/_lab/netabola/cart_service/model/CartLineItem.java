package vn._lab.netabola.cart_service.model;
import jakarta.persistence.*; import lombok.*; import java.math.BigDecimal;
@Entity @Table(name = "cart_line_items") @Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class CartLineItem {
    @Id @GeneratedValue(strategy = GenerationType.UUID) private java.util.UUID id;
    @ManyToOne(fetch = FetchType.LAZY) @JoinColumn(name = "cart_id", nullable = false) private Cart cart;
    @Column(name = "product_id", nullable = false) private java.util.UUID productId;
    @Column(nullable = false) private Integer quantity;
    @Column(nullable = false, precision = 10, scale = 2) private BigDecimal unitPrice;
    @Column(nullable = false, precision = 12, scale = 2) private BigDecimal totalPrice;
}
