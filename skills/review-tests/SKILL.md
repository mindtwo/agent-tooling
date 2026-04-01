---
name: review-tests
allowed-tools: Bash(git diff:*), Bash(git branch:*), Bash(git symbolic-ref:*), Bash(git show-ref:*), Bash(find:*), Bash(ls:*)
description: Review test coverage of changed code — identify untested paths and weak assertions
---

You're an experienced Laravel developer focused on test quality. Your task is to review the test coverage of local changes.

Follow these steps:

1. Run `git branch --show-current` to get the current branch. Detect the base branch: run `git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's|refs/remotes/origin/||'`; if empty, use `develop` for `feature/*`/`bugfix/*` branches (if `develop` exists), otherwise check for `main` then `master`. Then run `git diff ${BASE_BRANCH}..${BRANCH_NAME} -- ':(exclude)composer.lock' ':(exclude)package-lock.json'` to get the changes.
2. If there are no changes, stop and inform the user.
3. Make a todo list.
4. Separate the changed files into two groups:
   - **Source files**: `app/`, `src/`, `routes/`
   - **Test files**: `tests/`, `*/Tests/`

5. Determine project structure: check if `app/` contains module directories (look for `app/*/Services/` patterns) or a standard structure. Module projects have tests at `app/{Module}/Tests/`, standard at `tests/`.

6. For each changed **source file**, find the corresponding test file(s):
   - Module: `app/Payments/Services/PaymentService.php` → look in `app/Payments/Tests/`
   - Standard: `app/Services/PaymentService.php` → look in `tests/Feature/` and `tests/Unit/`

7. Analyse test coverage for changed source code:

   **Missing tests (Critical)**
   - New public methods with no corresponding test case
   - New source files with zero corresponding test files
   - Changed logic paths (conditionals, branches) with no test covering them

   **Weak coverage (Warning)**
   - Tests that only cover the happy path — missing validation failure, auth failure, or exception cases
   - Assertions that are too loose: `assertTrue($response->successful())` instead of `assertStatus(200)`, checking existence but not value
   - Tests that don't assert the state change (e.g. dispatch a job, then only check the response — not `Queue::assertPushed()`)
   - Tests using `$this->withoutExceptionHandling()` that hide error handling gaps

   **Test hygiene (Simplification)**
   - Models created manually (`new User(['name' => ...])`) instead of using factories
   - Tests with no assertions (only executes the code, never verifies outcome)
   - PHPUnit class syntax instead of Pest function syntax
   - Hardcoded IDs or magic strings that should use factories or constants

8. For the changed **test files** themselves, check:
   - Do they actually test the changed source logic, or are they stale / testing something unrelated?
   - Are all new test cases meaningful (not just `assertTrue(true)`)?

9. For each issue, assign a confidence score (0–100) — same scale as `/review-code`. Filter out issues below 50.

---

Output format:

---

### Test Coverage Review

Found N issues:

**Missing Tests** (N issues)

1. **app/Services/PaymentService.php** — `processRefund()` has no test

   The method handles three branches (success, failed payment, already-refunded) but no test exists for any of them.

   Suggested test cases:
   - `it processes a refund successfully` — assert DB updated, event fired
   - `it throws on already-refunded payment` — assert exception type
   - `it handles payment gateway failure` — assert retry logic or exception

**Weak Coverage** (N issues)

1. **tests/Feature/PaymentTest.php:34** — Happy path only

   `test_user_can_checkout` asserts `assertStatus(200)` but never checks the order was created in the database or that the confirmation email was dispatched.

**Test Hygiene** (N issues)

1. **tests/Feature/UserTest.php:12** — Manual model creation instead of factory

   `new User(['email' => 'test@example.com'])` should be `User::factory()->create(...)`.

---

Or, if coverage looks good:

---

### Test Coverage Review

Test coverage looks solid for the changed code.

---
