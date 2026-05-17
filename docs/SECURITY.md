# Security Audit Report

## OWASP Top 10 Analysis

### A01:2021 - Broken Access Control
- Order checkout verifies ownership: `!order.getUserId().equals(userId)`
- Gateway enforces JWT on all routes except `/api/auth/**`
- Status: Mitigated

### A02:2021 - Cryptographic Failures
- JWT RS256 signing with RSA 4096-bit keys
- Keys persisted to disk at `{tmpdir}/netabola-keys/`
- BCrypt for password encoding
- Status: Mitigated

### A03:2021 - Injection
- JPA parameterized queries throughout
- No raw SQL execution
- Status: Mitigated

### A05:2021 - Security Misconfiguration
- Security headers filter applied globally
- HSTS enabled
- Status: Mitigated

### A07:2021 - Identification and Authentication Failures
- JWT RS256 with rotation
- Refresh token rotation + revocation
- Rate limiting: 100 req/min per IP
- Status: Mitigated
