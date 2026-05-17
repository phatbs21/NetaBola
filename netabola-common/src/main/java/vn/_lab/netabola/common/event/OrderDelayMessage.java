package vn._lab.netabola.common.event;
import lombok.Builder; import lombok.Data;
@Data @Builder
public class OrderDelayMessage {
    private String orderId; private int delayMinutes;
}
