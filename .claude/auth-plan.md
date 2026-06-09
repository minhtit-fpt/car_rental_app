# Auth Plan — RideVN (Phone + Password)

> Generated: 2026-06-09
> Flows: Register · Login · Refresh token rotation · Logout
> Out of scope this phase: OTP SMS verification

---

## Schema (no migration needed)

Tables already in DB:
- `User` — phone UNIQUE, passwordHash, roles[], kycStatus
- `RefreshToken` — tokenHash (SHA-256 hash of opaque token), userId, expiresAt, revokedAt
- `OTPCode` — reserved for later

---

## Dependencies to add (require team approval)

### Backend (`package.json`)
| Package | Reason |
|---|---|
| `bcryptjs` + `@types/bcryptjs` | Password hashing (pure-JS, serverless-safe) |
| `jose` | JWT sign/verify, Edge-runtime compatible |
| `ioredis` | Rate limiting on `/api/auth/*` (required by CLAUDE.md) |

### Flutter (`pubspec.yaml`)
`flutter_bloc`, `equatable`, `go_router`, `dio`, `get_it`,
`flutter_secure_storage`, `google_fonts`

---

## BACKEND PHASES

### B1 — Auth infrastructure
Branch: `feature/auth-b1-infra`

Files:
- `src/lib/config/env.ts` — Zod env validation (JWT_ACCESS_SECRET, JWT_ACCESS_TTL, JWT_REFRESH_TTL_DAYS, DATABASE_URL, REDIS_URL)
- `src/lib/auth/password.ts` — hashPassword / verifyPassword (bcryptjs)
- `src/lib/auth/jwt.ts` — sign / verify access token (jose, HS256), payload: sub, roles, kycStatus
- `src/lib/auth/refresh-token.ts` — opaque token generation + SHA-256 hash
- `.env.example` — add all required vars (no real secrets)

---

### B2 — Repositories + Validators
Branch: `feature/auth-b2-repo-validators`

Files:
- `src/lib/repositories/user.repository.ts` — findByPhone, findById, create
- `src/lib/repositories/refresh-token.repository.ts` — create, findByHash, revoke, revokeAllForUser
- `src/lib/validators/auth.validator.ts` — Zod schemas:
  - registerSchema: phone (VN-normalized), password ≥8 chars, email optional, roles default [RENTER]
  - loginSchema: phone + password
  - refreshSchema: refreshToken string

---

### B3 — Service (business logic)
Branch: `feature/auth-b3-service`

File: `src/lib/services/auth.service.ts`

- `register` → check duplicate phone → hash pw → create user [RENTER] → issue tokens
- `login` → verify pw → issue tokens
- `refresh` → lookup by hash → if revokedAt set (reuse attack) → revoke ALL user tokens; else rotate (revoke old, issue new)
- `logout` → revoke the submitted refresh token
- `getCurrentUser` → return user by sub from access token

---

### B4 — Middleware + Route handlers
Branch: `feature/auth-b4-routes`

Files:
- `src/lib/middleware/auth.middleware.ts` — verify access JWT (jose), attach user to request, return 401
- `src/lib/middleware/rate-limit.middleware.ts` — ioredis sliding window, tighter on auth routes
- `src/app/api/auth/register/route.ts` → POST 201
- `src/app/api/auth/login/route.ts` → POST 200
- `src/app/api/auth/refresh/route.ts` → POST 200
- `src/app/api/auth/logout/route.ts` → POST 200
- `src/app/api/auth/me/route.ts` → GET 200 (protected; Flutter uses this to restore session)

All responses: `{ success, data }` / `{ success, error, code }`

---

### B5 — Backend tests (vitest, ≥80%)
Branch: `feature/auth-b5-tests`

- Unit: password, jwt, refresh-token utils, validators, auth.service (mock repos)
  - Covers: rotation, reuse-detection (revoke-all), duplicate phone, wrong password
- Integration: 5 route handlers, happy path + 400/401/409

---

## FLUTTER PHASES

### F1 — Core scaffolding
Branch: `feature/auth-f1-core`

```
core/config/     env.dart + api_endpoints.dart
core/storage/    secure_token_storage.dart (flutter_secure_storage)
core/network/    dio_client.dart + auth_interceptor.dart (Bearer + refresh-on-401 single-flight + retry)
core/di/         service_locator.dart (get_it setup)
core/router/     app_router.dart (go_router + redirect guard from AuthCubit)
```

---

### F2 — Feature `auth` (Clean Architecture)
Branch: `feature/auth-f2-feature`

```
features/auth/
├── data/
│   ├── datasources/   auth_remote_datasource.dart
│   ├── models/        auth_user_model · auth_tokens_model · auth_response_model
│   └── repositories/  auth_repository_impl.dart
├── domain/
│   ├── entities/      auth_user.dart · auth_tokens.dart
│   ├── repositories/  auth_repository.dart (interface)
│   └── usecases/      login · register · logout · refresh · get_current_user
└── presentation/
    ├── bloc/          auth_cubit.dart + auth_state.dart
    │                  states: AuthUnknown · AuthAuthenticated(user) · AuthUnauthenticated
    ├── screens/       login_screen.dart · register_screen.dart
    └── widgets/       phone_field.dart · password_field.dart · auth_button.dart
```

Flow: `UI → Cubit → Usecase → Repository → Datasource → API`

AuthCubit bootstrap: read tokens from secure storage → call /auth/me → emit authenticated or unauthenticated.

---

### F3 — App shell integration
Branch: `feature/auth-f3-integration`

- `main.dart`: setupDependencies() + MaterialApp.router(app_router) + BlocProvider<AuthCubit>
- Router redirect: unauthenticated → `/login`; authenticated → `_AppShell` (existing bottom nav)
- Profile tab placeholder gets a Logout button (calls AuthCubit.logout())
- UI: AppColors.* only, card/gradient per CLAUDE.md, renterHeaderGradient on auth screens
- Note: app_colors.dart tokens (primary #007BFF) take precedence over CLAUDE.md token table until AppColors is updated

---

### F4 — Flutter tests (≥80% business logic)
Branch: `feature/auth-f4-tests`

- Unit: usecases (login/register/logout/refresh), auth_repository_impl (fake datasource), AuthCubit (bloc_test)
  - Covers: success, wrong credentials, network error, refresh rotation, logout
- Widget: login/register form validation, loading state, error display

---

## Risks

| Level | Risk | Mitigation |
|---|---|---|
| HIGH | New deps need approval | Listed above — confirm before install |
| HIGH | Refresh reuse attack | revoke-all on hash already-revoked |
| HIGH | Rate limit mandatory (CLAUDE.md) | ioredis middleware on all /api/auth/* |
| MED | jose vs Edge runtime | jose is Edge-compatible; flag if issue |
| MED | user_admin_exclusive CHECK | Register hardcodes [RENTER]; validator blocks ADMIN |
| MED | AppColors token mismatch | Follow app_colors.dart; update tokens separately |
| LOW | VN phone normalization | util in validator (+84 / 0xxx) |

---

## Implementation order

B1 → B2 → B3 → B4 → B5 (TDD per phase), then F1 → F2 → F3 → F4.
Backend can be tested standalone before connecting Flutter.
