package vn._lab.netabola.auth_service.repository;
import org.springframework.data.jpa.repository.JpaRepository;
import vn._lab.netabola.auth_service.model.RefreshToken;
import java.util.Optional; import java.util.UUID;
public interface RefreshTokenRepository extends JpaRepository<RefreshToken, Long> {
    Optional<RefreshToken> findByToken(String token);
    int deleteByUserId(UUID userId);
}
