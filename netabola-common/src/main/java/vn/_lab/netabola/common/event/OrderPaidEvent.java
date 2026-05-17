package vn._lab.netabola.common.event;
import lombok.Builder; import lombok.Data;
@Data @Builder
public class OrderPaidEvent implements DomainEvent {
    private String orderId; private String userId;
    private String paymentId; private java.time.Instant paidAt;
    public String getAggregateId() { return orderId; }
    public java.time.Instant getTimestamp() { return paidAt; }
}
