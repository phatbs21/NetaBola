package vn._lab.netabola.common.event;
public interface DomainEvent {
    String getAggregateId();
    java.time.Instant getTimestamp();
}
