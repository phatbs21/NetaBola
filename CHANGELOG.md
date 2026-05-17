# Changelog

## [0.0.1-SNAPSHOT] - 2025-04-18

### Added
- Auth service with JWT RS256
- Product, Cart, Order services
- API Gateway with JWT filter and rate limiting
- Loyalty service with RabbitMQ
- Kubernetes deployment manifests
- Docker Compose for local dev

### Security
- RSA 4096-bit keys for JWT
- Refresh token rotation
- Rate limiting (100 req/min)
- Security headers
- Circuit breakers
