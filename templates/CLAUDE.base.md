---
description: Team conventions and code quality guardrails for all projects
alwaysApply: true
---

# Team Conventions

> This file is managed by agent-tooling. It complements project-specific CLAUDE.md files
> (e.g. from Laravel Boost) — it does not duplicate them.
> When there is a conflict between this file and a generated project CLAUDE.md, these
> conventions take precedence.

---

## Philosophy

- **KISS**: Choose the simplest solution that works. If a junior dev can't understand it in 30 seconds, it's too complex.
- **YAGNI**: Do not build features, abstractions, or flexibility that is not needed right now.
- **SOLID**: Single responsibility — a class has one reason to change.
- **Low abstraction**: Prefer explicit over clever. One level of indirection is fine, two is suspicious, three needs justification.
- **Avoid magic**: No implicit model binding, global scopes, or dynamic relationships when explicit code would be clearer.

---

## What Claude Must NOT Do

- Create base classes, interfaces, abstractions, or DTOs unless explicitly asked.
- Refactor existing code unless asked — stay focused on the task.
- Add dependencies (`composer require`, `npm install`) without explicit developer approval.
- Add docblocks or comments that describe what the code does. Comment only _why_, and only when it isn't obvious.
- Over-engineer. A 10-line solution beats a 50-line "clean" one. Three similar lines are better than a premature abstraction.
- Use `env()` anywhere except config files.

---

## Architecture Patterns

- **Services**: `readonly` classes with constructor injection. All business logic lives here. Controllers, jobs, and commands are thin layers that accept input and delegate to services.
- **Repositories**: Only for complex, multi-line queries. Extend `AbstractRepository` from `chiiya/laravel-utilities`. Simple Eloquent queries (one or two lines) go directly where they're needed — do not wrap them in a repository method.
- **Pipelines**: For sequential multi-step processes. The pipeline class extends `Illuminate\Pipeline\Pipeline` and defines `$pipes`. Each pipe is an Action class with `handle($data, Closure $next): mixed`.
- **Controllers**: Thin. Accept input via Form Request, delegate to service, return response.
- **Presenters**: For view presentation logic, extend `Chiiya\Common\Presenter\Presenter`.
- **Enumerators**: PHP 8.1+ backed enums. The directory is named `Enumerators/` (not `Enums/`).
- **DTOs**: Plain PHP classes with constructor-promoted properties. No need for a base class.

---

## PHP Conventions

- `declare(strict_types=1)` in every PHP file, immediately after `<?php`.
- Return types on all methods. Parameter types on all parameters.
- `readonly` on service classes.
- Constructor property promotion.
- Early returns to reduce nesting — avoid `else` after a `return`.
- `Model::query()->` over `Model::` for Eloquent query chains.
- No `DB::` facade when Eloquent can do it.
- No `env()` outside of `config/` files.

---

## Project Structure

This team uses two project structures. Check `composer.json` for `nwidart/laravel-modules` or read the project's CLAUDE.md to determine which applies.

**Simple projects** (standard Laravel):
```
app/Models/
app/Services/
app/Http/Controllers/
app/Http/Requests/
tests/Feature/
tests/Unit/
```

**Module projects** (`nwidart/laravel-modules`):
```
app/{Module}/Models/
app/{Module}/Services/
app/{Module}/Repositories/
app/{Module}/Http/Controllers/
app/{Module}/Http/Requests/
app/{Module}/Tests/Feature/
app/{Module}/Tests/Unit/
```
For module projects: always add code to the correct module. Use `php artisan module:make-*` to scaffold files.

---

## Testing

- **Pest** syntax exclusively (not PHPUnit class syntax).
- Every feature and bugfix must have tests. No exceptions.
- Use factories — never create models manually in tests.
- Cover: happy path, validation failures, authorization, at least one edge case.
- Use `Queue::fake()`, `Notification::fake()`, `Event::fake()` for side effects — never let tests trigger real external calls.
- Run affected tests during development; full suite before PR.

---

## Linting & Code Quality

- **chiiya/laravel-code-style**: ECS, Rector, PHP-CS-Fixer, Tlint. Run `just lint` (or project equivalent).
- **Larastan** at PHPStan level 8. Run `just quality` (or project equivalent).
- **GrumPHP** handles pre-commit linting — do not skip it.
- Never commit with linting or static analysis failures.

---

## Security

- **SQL injection**: Always use parameterized queries. Be especially careful with `whereRaw()`, `DB::raw()`, `selectRaw()`, `orderByRaw()` — only use them with bound parameters.
- **Path traversal**: Never concatenate user input into `base_path()`, `storage_path()`, `public_path()`, or `resource_path()`.
- **File uploads**: Always validate type, size, and extension. Never store uploaded files in a publicly accessible location without access control.
- **XSS**: Use `{{ }}` in Blade. Only use `{!! !!}` when absolutely necessary — document why in a comment.
- **Mass assignment**: `$guarded = ['id', 'created_at', 'updated_at']` is acceptable **only** when all input passed to `create()`/`fill()`/`update()` comes from `$request->validated()`. If any unvalidated input is ever passed, use explicit `$fillable` instead.
- **Authorization**: Use policies for model-level access control. Middleware alone is not sufficient.
- **Rate limiting**: All authentication endpoints must have throttle middleware.
- **Sensitive data**: No `env()` outside config. No hardcoded API keys. Never log passwords, tokens, or PII.

---

## Documentation

- **Technical docs**: Astro Starlight under `documentation/docs/`, following the Diataxis framework (tutorials, how-to guides, references, explanations).
- **API docs**: OpenAPI specs. Use Bruno collections for local API testing.

---

## Code Review

Before opening a PR:
1. Run `/review-code` — bugs, logic errors, simplification opportunities
2. Run `/review-security` — OWASP Top 10 + Laravel-specific security issues
3. All tests pass
4. Linting passes (`just lint`)
5. Larastan passes (`just quality`)

---

## Git

- Branch naming: `feature/short-description`, `fix/short-description`, `chore/short-description`
- Commit messages: imperative mood, under 72 characters, describe _why_ not _what_
- One logical change per commit
