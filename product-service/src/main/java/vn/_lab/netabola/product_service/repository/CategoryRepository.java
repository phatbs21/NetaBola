package vn._lab.netabola.product_service.repository;
import org.springframework.data.jpa.repository.JpaRepository;
import vn._lab.netabola.product_service.model.Category;
import java.util.UUID;
public interface CategoryRepository extends JpaRepository<Category, UUID> {}
