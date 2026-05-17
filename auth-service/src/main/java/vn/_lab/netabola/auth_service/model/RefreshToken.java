package vn._lab.netabola.auth_service.model;
import jakarta.persistence.*; import lombok.*; import java.time.Instant;
@Entity @Table(name = "refresh_tokens") @Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class RefreshToken {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY) private Long id;
    @Column(nullable = false) private String token;
    @ManyToOne(fetch = FetchType.LAZY) @JoinColumn(name = "user_id") private User user;
    @Column(name = "user_id") private java.util.UUID userId;
    @Column(name = "expires_at", nullable = false) private Instant expiresAt;
    @Column(name = "created_at") private Instant createdAt;
    public boolean isExpired() { return Instant.now().isAfter(expiresAt); }
}
