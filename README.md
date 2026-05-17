# NetaBola - E-Commerce Platform

Microservices architecture for an e-commerce platform with product catalog, shopping cart, order processing, and payments.

## Services
- `auth-service`: Authentication & Authorization (port 8081)
- `product-service`: Product catalog management (port 8082)
- `cart-service`: Shopping cart operations (port 8083)
- `order-service`: Order processing & Stripe payments (port 8084)
- `api-gateway`: API Gateway & Routing (port 8080)
- `loyalty-service`: Loyalty points & rewards (port 8085)

## Tech Stack
- Java 21, Spring Boot 3.5.14
- Spring Cloud Gateway
- PostgreSQL, Redis, RabbitMQ
- JWT RS256, BCrypt
- Stripe Payment
- Kubernetes ready

## Quick Start
```bash
docker-compose up -d
mvn clean install
```

## Security
- JWT RS256 authentication
- Refresh token rotation
- Rate limiting (100 req/min)
- Security headers
- Circuit breakers
- See [SECURITY.md](docs/SECURITY.md)
