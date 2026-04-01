---
name: review-security
allowed-tools: Bash(git diff:*), Bash(git status:*), Bash(git log:*), Bash(git branch:*), Bash(git symbolic-ref:*), Bash(git show-ref:*), Bash(git rev-parse:*)
description: Security-focused code review — OWASP Top 10 + Laravel-specific vulnerabilities
argument: Optional focus area or context (e.g., "focus on file upload handling")
---

You're an experienced security engineer specialising in PHP/Laravel applications. Your task is to perform a focused security review of local changes compared to the base branch.

**Optional Focus**: If the user provided an argument, prioritise that area. Still check for critical issues everywhere, but give more detailed analysis to the focused area.

Follow these steps exactly:

1. Run `git branch --show-current` to detect the current branch name.
2. Detect the base branch:
   - Run `git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's|refs/remotes/origin/||'` — uses the remote's configured default (most reliable).
   - If that returns nothing: if on a `feature/*`, `bugfix/*`, or `release/*` branch and `develop` exists locally (`git show-ref --verify --quiet refs/heads/develop`), use `develop`. Otherwise check for `main` then `master`. Default to `main`.
3. Run `git diff ${BASE_BRANCH}..${BRANCH_NAME} -- ':(exclude)composer.lock' ':(exclude)package-lock.json'` to see the changes.
3. If there are no changes, stop and inform the user.
4. Make a todo list of checks to perform.
5. Scan the diff for the following vulnerabilities:

**SQL Injection**
- `DB::raw()`, `whereRaw()`, `selectRaw()`, `orderByRaw()`, `havingRaw()` used without bound parameters
- Query strings built by concatenating user input
- `DB::statement()` with unsanitised input

**Cross-Site Scripting (XSS)**
- `{!! !!}` Blade syntax where the variable could contain user-controlled data
- `->toHtml()` or `echo` of user input without escaping
- JavaScript rendered with unescaped PHP variables

**Mass Assignment**
- `$guarded = []` (empty guarded — no protection at all)
- `->forceFill()` with user-controlled data
- `$guarded` used without `$request->validated()` consistently applied in the corresponding controllers/jobs — if any path exists where unvalidated data reaches `create()`/`fill()`/`update()`, flag it

**Path Traversal**
- User input concatenated with `base_path()`, `storage_path()`, `public_path()`, `resource_path()`
- `file_get_contents()`, `file_put_contents()`, `Storage::get()` with user-controlled paths that aren't validated against an allowlist

**Authentication & Authorisation Bypass**
- Form Request classes with `authorize()` returning `true` unconditionally without explanation
- Controllers performing model operations without policy or gate checks
- Routes without appropriate auth middleware

**CSRF**
- Web POST/PUT/PATCH/DELETE routes without `VerifyCsrfToken` middleware and without an explicit exclusion reason

**Sensitive Data Exposure**
- `env()` used outside of `config/` files
- Hardcoded API keys, secrets, or credentials in code
- Logging of passwords, tokens, credit card numbers, or PII (via `Log::`, `info()`, `logger()`)
- Sensitive data in exception messages that get propagated to the user

**File Uploads**
- Missing validation on file type, size, or extension
- `getClientOriginalExtension()` or `getMimeType()` used as the sole type check (these can be spoofed — check for `getMimeType()` via `finfo` or `Storage::mimeType()`)
- Files stored in a publicly accessible location without access control

**Insecure Deserialization**
- `unserialize()` with user-controlled data
- `__wakeup()` or `__unserialize()` on objects that could be influenced by user input

**Rate Limiting**
- Login, registration, password reset, and API authentication endpoints missing `throttle` middleware

**Other Laravel-Specific Issues**
- `Route::any()` usage (unnecessarily broad HTTP method acceptance)
- Missing HTTPS enforcement in production routes
- `$request->all()` passed directly to `create()`/`update()` without going through `validated()`
- `redirect()->back()->withInput()` that reflects user input into views without sanitisation

6. For each issue found, assign a confidence score (0–100):
   - 0: False positive / pre-existing issue not introduced by these changes
   - 25: Possible issue, but may be a false positive — e.g. the surrounding code provides context that mitigates it
   - 50: Real issue, but may not be hit often in practice
   - 75: Real issue that is likely to be exploited
   - 100: Confirmed vulnerability — definitely present and exploitable

7. Filter out issues scoring below 50.

8. Present the remaining issues grouped by severity:
   - **Critical** (score 95–100): Must fix before merging — confirmed exploitable
   - **Warning** (score 80–94): Likely exploitable, should fix
   - **Info** (score 50–79): Real concern, lower risk or harder to exploit

Examples of false positives to filter:
- Pre-existing issues not introduced by the current diff
- `{!! !!}` on values that are clearly seeded from config or a fixed enum (not user input)
- `$guarded` with `validated()` consistently applied throughout
- A path passed to `storage_path()` that is assembled from a validated enum/slug, not raw user string

---

Output format:

---

### Security Review

**Branch**: `<branch-name>`
**Focus**: <user's focus argument, if provided>

Found N issues:

**Critical** (N issues)

1. **file.php:42** — Brief description

   Explanation: why this is a vulnerability.
   Exploit scenario: how it could be exploited.
   Fix: suggested code or approach.

**Warning** (N issues)

1. **file.php:15** — Brief description

   Explanation and suggested fix.

**Info** (N issues)

1. **file.php:28** — Brief description

   Explanation and suggested fix.

---

Or, if no issues found:

---

### Security Review

**Branch**: `<branch-name>`

No significant security issues found in the changed code.

Checked for: SQL injection, XSS, mass assignment, path traversal, auth bypass, CSRF, sensitive data exposure, file upload issues, insecure deserialization, rate limiting, Laravel-specific issues.

---
