package vn._lab.netabola.auth_service.repository;
import org.springframework.data.jpa.repository.JpaRepository;
import vn._lab.netabola.auth_service.model.User;
import java.util.Optional; import java.util.UUID;
public interface UserRepository extends JpaRepository<User, UUID> {
    Optional<User> findByEmail(String email);
    boolean existsByEmail(String email);
}
