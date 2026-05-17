package vn._lab.netabola.loyalty_service.service;
import lombok.RequiredArgsConstructor; import lombok.extern.slf4j.Slf4j;
import org.springframework.amqp.rabbit.annotation.RabbitListener;
import org.springframework.stereotype.Service; import org.springframework.transaction.annotation.Transactional;
import vn._lab.netabola.common.event.OrderPaidEvent;
import vn._lab.netabola.loyalty_service.model.LoyaltyPoint;
import vn._lab.netabola.loyalty_service.model.LoyaltyTransaction;
import vn._lab.netabola.loyalty_service.model.TransactionType;
import vn._lab.netabola.loyalty_service.repository.LoyaltyPointRepository;
import vn._lab.netabola.loyalty_service.repository.LoyaltyTransactionRepository;
import java.math.BigDecimal; import java.time.Instant; import java.util.UUID;
@Service @RequiredArgsConstructor @Slf4j
public class LoyaltyService {
    private final LoyaltyPointRepository loyaltyPointRepository;
    private final LoyaltyTransactionRepository loyaltyTransactionRepository;
    @RabbitListener(queues = "order.paid")
    public void handleOrderPaid(OrderPaidEvent event) {
        int points = event.getTotalAmount().compareTo(BigDecimal.ZERO) > 0
            ? event.getTotalAmount().divide(new BigDecimal("1000"))
                .setScale(0, java.math.RoundingMode.DOWN).intValue() : 0;
        LoyaltyPoint lp = loyaltyPointRepository.findByUserId(UUID.fromString(event.getUserId()))
            .orElseGet(() -> LoyaltyPoint.builder()
                .userId(UUID.fromString(event.getUserId())).balance(0).build());
        lp.setBalance(lp.getBalance() + points);
        loyaltyPointRepository.save(lp);
        LoyaltyTransaction tx = LoyaltyTransaction.builder()
            .userId(UUID.fromString(event.getUserId())).type(TransactionType.EARNED)
            .points(points).orderId(UUID.fromString(event.getOrderId()))
            .description("Earned from order: " + event.getOrderId())
            .createdAt(Instant.now()).build();
        loyaltyTransactionRepository.save(tx);
        log.info("Loyalty points updated for user {}: {} points", event.getUserId(), points);
    }
    @Transactional
    public void addPoints(UUID userId, int points) {
        LoyaltyPoint lp = loyaltyPointRepository.findByUserId(userId)
            .orElseGet(() -> LoyaltyPoint.builder().userId(userId).balance(0).build());
        lp.setBalance(lp.getBalance() + points);
        loyaltyPointRepository.save(lp);
    }
}
