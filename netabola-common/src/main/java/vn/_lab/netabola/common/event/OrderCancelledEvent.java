package vn._lab.netabola.common.event;
import lombok.Builder; import lombok.Data;
@Data @Builder
public class OrderCancelledEvent implements DomainEvent {
    private String orderId; private String userId;
    private String reason; private java.time.Instant cancelledAt;
    public String getAggregateId() { return orderId; }
    public java.time.Instant getTimestamp() { return cancelledAt; }
}
