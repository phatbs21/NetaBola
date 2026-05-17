package vn._lab.netabola.common.event;
import lombok.Builder; import lombok.Data;
@Data @Builder
public class OrderCreatedEvent implements DomainEvent {
    private String orderId; private String userId;
    private java.math.BigDecimal totalAmount; private java.time.Instant createdAt;
    public String getAggregateId() { return orderId; }
    public java.time.Instant getTimestamp() { return createdAt; }
}
