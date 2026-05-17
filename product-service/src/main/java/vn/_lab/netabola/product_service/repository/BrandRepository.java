package vn._lab.netabola.product_service.repository;
import org.springframework.data.jpa.repository.JpaRepository;
import vn._lab.netabola.product_service.model.Brand;
import java.util.UUID;
public interface BrandRepository extends JpaRepository<Brand, UUID> {}
