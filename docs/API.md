# API Documentation

## Base URL: http://localhost:8080

## Auth
- POST /api/auth/register - Register new user
- POST /api/auth/login - Login
- POST /api/auth/refresh - Refresh token
- POST /api/auth/logout - Logout

## Products
- GET /api/products - List products (paginated)
- GET /api/products/{id} - Get product details
- POST /api/products - Create product (admin)
- PUT /api/products/{id} - Update product (admin)

## Cart
- GET /api/carts/current - Get current cart
- POST /api/carts/items - Add item to cart
- PUT /api/carts/items/{id} - Update cart item
- DELETE /api/carts/items/{id} - Remove cart item

## Orders
- GET /api/orders - List user orders
- GET /api/orders/{id} - Get order details
- POST /api/orders - Create order
- POST /api/orders/{id}/pay - Pay order (Stripe)
- POST /api/orders/{id}/cancel - Cancel order
- POST /api/checkout/stripe-session - Create Stripe checkout session
