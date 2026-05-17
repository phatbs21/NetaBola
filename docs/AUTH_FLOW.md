# Authentication Flow

1. User registers via POST /api/auth/register
2. Server returns access token + refresh token
3. Client includes access token in Authorization header
4. Gateway validates JWT and adds X-User-Id header
5. Service endpoints read X-User-Id from header
6. Refresh token used at POST /api/auth/refresh
7. Old refresh token revoked, new one issued

## JWT Claims
- sub: user UUID
- email: user email
- role: USER/ADMIN/MODERATOR
