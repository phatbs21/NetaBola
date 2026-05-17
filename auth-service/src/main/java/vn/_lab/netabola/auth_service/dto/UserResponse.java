package vn._lab.netabola.auth_service.dto;
import lombok.Builder; import lombok.Data; import vn._lab.netabola.auth_service.model.User;
import java.time.Instant;
@Data @Builder public class UserResponse {
    private String id; private String email; private String username;
    private String role; private Instant createdAt;
    public static UserResponse from(User user) {
        return UserResponse.builder().id(user.getId().toString()).email(user.getEmail())
            .username(user.getUsername()).role(user.getRole().name()).createdAt(user.getCreatedAt()).build();
    }
}
