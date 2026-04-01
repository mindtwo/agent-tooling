---
description: Team conventions and code quality guardrails for all projects
alwaysApply: true
---

# Team Conventions

> Managed by agent-tooling. These rules apply to all projects.
> **Project-level CLAUDE.md files always take precedence** over this file for
> project-specific conventions (architecture patterns, linting tools, test setup).

---

## Read the Project First

**Before writing any code, always:**

1. Check the project's own CLAUDE.md for project-specific conventions — follow them.
2. Scan `composer.json` and `package.json` to understand what tools are installed (linter, test runner, static analysis).
3. Look at 2–3 existing files similar to what you're about to create, and match their patterns.

**Match what's there.** If the project uses Actions instead of Services, use Actions. If it uses Pint instead of ECS, use Pint. If it uses PHPUnit instead of Pest, use PHPUnit. Do not introduce new patterns into an existing project just because they differ from the defaults below.

**Apply the defaults below only when:**
- Starting a new project from scratch
- Adding a new subsystem with no existing pattern to follow
- Explicitly asked to align the project with team conventions

---

## Philosophy (Always Apply)

- **KISS**: Choose the simplest solution that works. If a junior dev can't understand it in 30 seconds, it's too complex.
- **YAGNI**: Do not build features, abstractions, or flexibility that is not needed right now.
- **SOLID**: Single responsibility — a class has one reason to change.
- **Low abstraction**: Prefer explicit over clever. One level of indirection is fine, two is suspicious, three needs justification.
- **Avoid magic**: No implicit model binding, global scopes, or dynamic relationships when explicit code would be clearer.

---

## What Claude Must NOT Do (Always Apply)

- Create base classes, interfaces, abstractions, or DTOs unless explicitly asked.
- Refactor existing code unless asked — stay focused on the task.
- Add dependencies (`composer require`, `npm install`) without explicit developer approval.
- Add docblocks or comments that describe what the code does. Comment only _why_, and only when it isn't obvious.
- Over-engineer. A 10-line solution beats a 50-line "clean" one. Three similar lines are better than a premature abstraction.
- Use `env()` anywhere except config files.

---

## Security (Always Apply)

These rules apply to every project regardless of age or architecture.

- **SQL injection**: Always use parameterized queries. Be especially careful with `whereRaw()`, `DB::raw()`, `selectRaw()`, `orderByRaw()` — only use them with bound parameters.
- **Path traversal**: Never concatenate user input into `base_path()`, `storage_path()`, `public_path()`, or `resource_path()`.
- **File uploads**: Always validate type, size, and extension. Never store uploaded files in a publicly accessible location without access control.
- **XSS**: Use `{{ }}` in Blade. Only use `{!! !!}` when absolutely necessary — document why in a comment.
- **Mass assignment**: `$guarded = ['id', 'created_at', 'updated_at']` is acceptable **only** when all input passed to `create()`/`fill()`/`update()` comes from `$request->validated()`. If any unvalidated input is ever passed, use explicit `$fillable` instead.
- **Authorization**: Use policies for model-level access control. Middleware alone is not sufficient.
- **Rate limiting**: All authentication endpoints must have throttle middleware.
- **Sensitive data**: No `env()` outside config. No hardcoded API keys. Never log passwords, tokens, or PII.

---

## Git (Always Apply)

- Branch naming: `feature/short-description`, `fix/short-description`, `chore/short-description`
- Commit messages: imperative mood, under 72 characters, describe _why_ not _what_
- One logical change per commit

---

## Code Review (Always Apply)

Before opening a PR, run `/review-code` and `/review-security`. Ensure all tests pass and linting passes (using whatever tool the project uses).

---

## Default Conventions for New Projects

> Use these when there is no existing pattern to follow. Do not impose these on legacy projects.

### Architecture

- **Services**: `readonly` classes with constructor injection. All business logic lives here. Controllers, jobs, and commands are thin layers that accept input and delegate to services.
- **Repositories**: Only for complex, multi-line queries. Extend `AbstractRepository` from `chiiya/laravel-utilities`. Simple Eloquent queries go directly where they're needed.
- **Pipelines**: For sequential multi-step processes. The pipeline class extends `Illuminate\Pipeline\Pipeline` with an array of pipe classes, each implementing `handle($data, Closure $next): mixed`.
- **Controllers**: Thin. Accept input via Form Request, delegate to service, return response.
- **Presenters**: For view presentation logic, extend `Chiiya\Common\Presenter\Presenter`.
- **Enumerators**: PHP 8.1+ backed enums. Directory named `Enumerators/` (not `Enums/`).
- **DTOs**: Plain PHP classes with constructor-promoted properties.

### PHP

- `declare(strict_types=1)` in every file, immediately after `<?php`.
- Return types on all methods. Parameter types on all parameters.
- `readonly` on service classes.
- Constructor property promotion.
- Early returns to reduce nesting — avoid `else` after a `return`.
- `Model::query()->` over `Model::` for Eloquent query chains.
- No `DB::` facade when Eloquent can do it.

### Project Structure

Check `composer.json` for `nwidart/laravel-modules`. If present, it's a module project.

**Standard Laravel**: `app/Models/`, `app/Services/`, `tests/Feature/`, `tests/Unit/`

**Module project**: `app/{Module}/Models/`, `app/{Module}/Services/`, `app/{Module}/Tests/Feature/`, etc. Always add code to the correct module. Use `php artisan module:make-*` to scaffold.

### Testing

- **Pest** syntax (`it('...', function () { ... })`), not PHPUnit class syntax.
- Every feature and bugfix must have tests.
- Use factories — never create models manually in tests.
- Cover: happy path, validation failures, authorization, at least one edge case.
- Use `Queue::fake()`, `Notification::fake()`, `Event::fake()` for side effects.

### Linting & Quality

- **chiiya/laravel-code-style** (ECS, Rector, PHP-CS-Fixer, Tlint) + **Larastan** at level 8.
- Run `just lint` and `just quality` (or the project's equivalent commands).
- GrumPHP handles pre-commit linting — do not skip it.

### Documentation

- Astro Starlight under `docs/`, following the Diataxis framework.
- OpenAPI specs for API documentation. Bruno collections for local API testing.
