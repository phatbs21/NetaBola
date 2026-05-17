# Architecture

## Service Communication
- Synchronous: REST via API Gateway
- Asynchronous: RabbitMQ for domain events
- State: Each service has its own database

## Request Flow
1. Client -> API Gateway (port 8080)
2. Gateway validates JWT, adds X-User-Id
3. Gateway routes to appropriate service
4. Service processes request
5. Service publishes events to RabbitMQ
6. Loyalty service consumes OrderPaidEvent

## Security Layers
1. Gateway JWT filter
2. Gateway security headers
3. Gateway rate limiting
4. Service-level security filters
