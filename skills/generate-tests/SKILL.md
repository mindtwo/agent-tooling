---
name: generate-tests
allowed-tools: Bash(find:*), Bash(ls:*), Bash(grep:*), Read
description: Generate Pest test scaffolding for a class or feature
argument: File path or class name to generate tests for (e.g., "app/Services/PaymentService.php" or "PaymentService")
---

You're an experienced Laravel developer writing high-quality Pest tests.

Follow these steps:

1. If the user provided a file path, read that file. If they provided a class name, search for it:
   `find . -name "*.php" -path "*/Services/*" | xargs grep -l "class $ARGUMENT" 2>/dev/null`
   Adjust the path pattern for other class types (Controllers, Jobs, etc.).

2. Read the source file fully. Identify:
   - All public methods
   - Constructor dependencies (what needs to be mocked or set up)
   - Eloquent relationships used
   - Events dispatched, jobs dispatched, notifications sent
   - External calls (HTTP, APIs, file system)

3. Determine the correct test file location:
   - If the source is in `app/{Module}/`, create the test at `app/{Module}/Tests/Feature/{ClassName}Test.php` (or `Unit/` for pure logic with no DB/HTTP)
   - If standard structure, create at `tests/Feature/{ClassName}Test.php`

4. Check for any existing test file at that path and read it to match its style. Read 1–2 other test files in the same directory to understand project conventions.

5. Determine test type:
   - **Unit test**: Pure logic, no database, no HTTP — use `it()` with mocked dependencies
   - **Feature test**: Database interactions, HTTP requests, queues — use `it()` with `RefreshDatabase` and factories

6. Generate the test file. Follow these rules:
   - Pest function syntax: `it('does something', function () { ... });`
   - `uses(RefreshDatabase::class)` for feature tests
   - Use factories for all model creation: `User::factory()->create([...])`
   - Use `Queue::fake()`, `Event::fake()`, `Notification::fake()` for side effects
   - `actingAs($user)` for authenticated requests
   - Cover each public method with at minimum:
     - Happy path
     - Validation failure (if the method validates input)
     - Authorisation failure (if the method checks permissions)
     - At least one edge case or error path
   - No `assertTrue(true)` or empty assertions
   - Test names should read like sentences: `it creates an order when payment succeeds`

7. Show the proposed file path and full test contents. Ask: "Write this to `<path>`?"
   Wait for confirmation before writing.

8. After writing, remind the developer to run: `./vendor/bin/pest <test-file-path>` to verify the scaffolding runs.
