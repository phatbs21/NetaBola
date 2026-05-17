package vn._lab.netabola.order_service.controller;
import lombok.RequiredArgsConstructor; import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import vn._lab.netabola.order_service.model.Order;
import vn._lab.netabola.order_service.service.OrderService;
@RestController @RequestMapping("/api/checkout") @RequiredArgsConstructor
public class CheckoutController {
    private final OrderService orderService;
    @PostMapping("/stripe-session") public ResponseEntity<?> createCheckoutSession(
            @RequestHeader("X-User-Id") String userId, @RequestBody CheckoutRequest req) {
        Order order = orderService.findOrderForCheckout(req.orderId(), userId);
        return ResponseEntity.ok(order);
    }
    public record CheckoutRequest(String orderId) {}
}
