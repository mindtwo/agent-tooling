---
name: audit-routes
allowed-tools: Bash(php artisan route:list:*), Bash(find:*), Bash(grep:*)
description: Audit Laravel routes for security and convention issues
---

You're an experienced Laravel developer auditing the application's routes.

Follow these steps:

1. Run `php artisan route:list --json 2>/dev/null` to get all routes. If this fails (e.g. not a Laravel project root), inform the user and stop.

2. Parse the JSON output and build a picture of the routes: name, method, URI, middleware, action.

3. Check for the following issues:

**Security issues (Critical/Warning)**
- Routes with no authentication middleware (no `auth`, `auth:api`, `auth:sanctum`, etc.) that appear to handle user-specific data — look for URIs containing `{id}`, `user`, `account`, `admin`, `dashboard`
- Auth-related routes (login, register, password reset, 2FA) missing `throttle` middleware
- `Route::any()` usage — unnecessarily broad, flags all HTTP methods
- Routes that point to closures instead of controllers (`Closure` in action column) — hard to test and cache

**Naming conventions (Warning)**
- Unnamed routes (missing name) — makes `route()` helper unusable and links fragile
- Route names that don't follow `resource.action` convention (e.g. `user.index`, `user.show`) — inconsistencies make the codebase harder to navigate

**Structure (Info)**
- API routes not prefixed with `/api/` or missing `api` middleware group
- Web routes that should probably be API routes (JSON responses on `/` prefixed URIs)
- Very long route files — suggest grouping into route files by module if > 50 routes in one file

4. For each issue, note the route name, URI, and method.

5. Additionally, scan route files for policy usage:
   Run `grep -r "authorizeResource\|authorize(" routes/ app/Http/Controllers/ 2>/dev/null | head -20`
   If resource controllers exist with no `authorizeResource()` or `->middleware('can:...')`, flag the top offenders.

---

Output format:

---

### Route Audit

**Total routes**: N

**Security** (N issues)

1. **GET /users/{id}/profile** (`user.profile`) — No authentication middleware

   This route accesses user-specific data but has no `auth` middleware.
   Fix: Add to an `auth` middleware group or add `->middleware('auth')`.

**Naming** (N issues)

1. **POST /save-user** — Unnamed route

   Unnamed routes can't be referenced with `route()`. Add `->name('user.update')`.

**Structure** (N issues)

1. **POST /get-orders** (`orders`) — Verb in URI

   REST convention uses HTTP methods to express actions, not URI verbs.
   Consider `POST /orders` → creates, `GET /orders` → lists.

---

Or if everything looks good:

---

### Route Audit

**Total routes**: N

No significant issues found.

---
