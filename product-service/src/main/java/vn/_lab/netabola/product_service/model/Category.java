package vn._lab.netabola.product_service.model;
import jakarta.persistence.*; import lombok.*;
@Entity @Table(name = "categories") @Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class Category {
    @Id @GeneratedValue(strategy = GenerationType.UUID) private java.util.UUID id;
    @Column(nullable = false, unique = true) private String name;
    @Column(length = 500) private String description;
}
