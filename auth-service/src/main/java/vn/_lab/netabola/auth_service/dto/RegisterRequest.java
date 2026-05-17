package vn._lab.netabola.auth_service.dto;
import jakarta.validation.constraints.*; import lombok.Data;
@Data public class RegisterRequest {
    @NotBlank @Email private String email;
    @NotBlank @Size(min = 8) private String password;
    @NotBlank @Size(min = 3, max = 50) private String username;
}
