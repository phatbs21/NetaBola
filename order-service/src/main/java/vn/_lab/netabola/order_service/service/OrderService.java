package vn._lab.netabola.order_service.service;
import lombok.RequiredArgsConstructor; import lombok.extern.slf4j.Slf4j;
import org.springframework.amqp.rabbit.core.RabbitTemplate;
import org.springframework.stereotype.Service; import org.springframework.transaction.annotation.Transactional;
import vn._lab.netabola.common.event.OrderCreatedEvent;
import vn._lab.netabola.common.event.OrderDelayMessage;
import vn._lab.netabola.order_service.model.Order;
import vn._lab.netabola.order_service.model.OrderStatus;
import vn._lab.netabola.order_service.repository.OrderRepository;
import java.time.Instant; import java.util.UUID;
@Service @RequiredArgsConstructor @Slf4j
public class OrderService {
    private final OrderRepository orderRepository;
    private final RabbitTemplate rabbitTemplate;
    @Transactional
    public Order createOrder(UUID userId, java.math.BigDecimal totalAmount) {
        Order order = Order.builder().userId(userId).status(OrderStatus.PENDING)
            .totalAmount(totalAmount).createdAt(Instant.now()).build();
        order = orderRepository.save(order);
        log.info("Order created: {}", order.getId());
        rabbitTemplate.convertAndSend("order.events", "order.created",
            OrderCreatedEvent.builder().orderId(order.getId().toString()).userId(userId.toString())
                .totalAmount(totalAmount).createdAt(Instant.now()).build());
        return order;
    }
    @Transactional
    public Order findOrderForCheckout(String orderId, String userId) {
        Order order = orderRepository.findById(UUID.fromString(orderId)).orElseThrow(() -> new RuntimeException("Order not found"));
        if (!order.getUserId().toString().equals(userId)) throw new RuntimeException("Order not owned by user");
        return order;
    }
    public Order getOrder(String orderId) {
        return orderRepository.findById(UUID.fromString(orderId)).orElseThrow();
    }
    @Transactional
    public Order payOrder(String orderId, String stripePaymentId) {
        Order order = orderRepository.findById(UUID.fromString(orderId)).orElseThrow();
        order.setStripePaymentId(stripePaymentId);
        order.setStatus(OrderStatus.PAID);
        order.setPaidAt(Instant.now());
        order.setUpdatedAt(Instant.now());
        log.info("Order paid: {}", order.getId());
        return orderRepository.save(order);
    }
    @Transactional
    public Order cancelOrder(String orderId, String reason) {
        Order order = orderRepository.findById(UUID.fromString(orderId)).orElseThrow();
        order.setStatus(OrderStatus.CANCELLED);
        order.setCancelledReason(reason);
        order.setCancelledAt(Instant.now());
        order.setUpdatedAt(Instant.now());
        log.info("Order cancelled: {}", order.getId());
        return orderRepository.save(order);
    }
}
