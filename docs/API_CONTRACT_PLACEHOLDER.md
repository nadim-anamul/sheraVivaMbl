# Next.js API Contract Placeholder

Replace placeholder paths in lib/core/network/api_config.dart with real endpoints when available.

## Required Endpoints
- POST /auth/login
- POST /auth/refresh
- POST /viva/form
- GET /viva/history
- GET /dashboard/summary

## Required Headers
- Authorization: Bearer <access_token>
- Content-Type: application/json

## TODO Mapping
1. Define request/response DTO for each endpoint.
2. Define error code mapping (401, 403, 422, 500).
3. Confirm token refresh strategy and expiry semantics.
4. Confirm LiveKit token endpoint (room create/token issue).
