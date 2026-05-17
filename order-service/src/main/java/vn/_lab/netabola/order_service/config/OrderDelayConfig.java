package vn._lab.netabola.order_service.config;
import org.springframework.amqp.rabbit.annotation.RabbitListener;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;
import lombok.RequiredArgsConstructor; import lombok.extern.slf4j.Slf4j;
import vn._lab.netabola.order_service.model.OrderStatus;
import vn._lab.netabola.order_service.repository.OrderRepository;
import java.time.Instant;
@Component @RequiredArgsConstructor @Slf4j
public class OrderDelayConfig {
    private final OrderRepository orderRepository;
    @Value("${order.delay-minutes:15}") private int delayMinutes;
    @RabbitListener(queues = "order.delay")
    public void handleDelayMessage(String message) {
        log.info("Processing delay for: {}", message);
    }
}
