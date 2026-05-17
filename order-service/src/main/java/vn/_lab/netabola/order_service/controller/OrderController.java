package vn._lab.netabola.order_service.controller;
import lombok.RequiredArgsConstructor; import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import vn._lab.netabola.order_service.service.OrderService;
import java.util.UUID;
@RestController @RequestMapping("/api/orders") @RequiredArgsConstructor
public class OrderController {
    private final OrderService orderService;
    @GetMapping("/{orderId}") public ResponseEntity<?> getOrder(@PathVariable String orderId) {
        return ResponseEntity.ok(orderService.getOrder(orderId));
    }
    @PostMapping("/{orderId}/pay") public ResponseEntity<?> payOrder(@PathVariable String orderId,
            @RequestHeader("X-User-Id") String userId, @RequestBody PayRequest req) {
        return ResponseEntity.ok(orderService.payOrder(orderId, req.stripePaymentId()));
    }
    @PostMapping("/{orderId}/cancel") public ResponseEntity<?> cancelOrder(@PathVariable String orderId,
            @RequestHeader("X-User-Id") String userId, @RequestBody CancelRequest req) {
        return ResponseEntity.ok(orderService.cancelOrder(orderId, req.reason()));
    }
    public record PayRequest(String stripePaymentId) {}
    public record CancelRequest(String reason) {}
}
