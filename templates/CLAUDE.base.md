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
- **Extraction checklist**: When an extraction is asked for, only extract a shared utility/DTO if the duplication is more than ~5 lines, there are 2+ real callers, and the abstraction doesn't force a worse data flow (e.g. loading everything into memory instead of streaming).
- **Avoid magic**: No implicit model binding, global scopes, or dynamic relationships when explicit code would be clearer.
- **Trust internal data**: No defensive fallbacks for developer-controlled data (config, settings rows, seeded platforms, hard-coded registries). Reserve validation and fallbacks for real userland boundaries — request input, uploads, third-party API responses, webhooks.
- **Prevent errors in UX, not error messages**: For conflicts users hit in normal flow, disable the affordance in the frontend rather than surfacing a backend 422. Keep the backend validation as the safety net.

---

## What Claude Must NOT Do (Always Apply)

- Create base classes, interfaces, abstractions, or DTOs unless explicitly asked.
- Refactor existing code unless asked — stay focused on the task.
- Add dependencies (`composer require`, `npm install`) without explicit developer approval.
- Add docblocks or comments that describe what the code does. Comment only _why_, and only when it isn't obvious. Never write a comment that only makes sense relative to the current diff (e.g. referencing removed code) — that context belongs in the commit message.
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
- Never invent the _why_: if the motivation for a change wasn't stated, ask — or describe only what changed. Plausible-sounding guesses misrepresent intent in the permanent history.
- One logical change per commit

---

## Code Review (Always Apply)

Before opening a PR, run `/review-code` and `/review-security`. Ensure all tests pass and linting passes (using whatever tool the project uses).

---

## Refactoring & Migrations (Always Apply)

- **Never silently drop API fields.** When rewriting a resource or endpoint, compare the new shape field-by-field against the legacy response before removing anything — frontends may depend on fields that look redundant. When in doubt, ask.
- **Verify output parity on dependency swaps.** Before replacing one package with another, read the relevant source of both and map every emitted field/behavior. Treat "the new one is much simpler" as a flag to look harder, not as confirmation.
- **Long-lived docs hold durable facts only.** CLAUDE.md files, guidelines, and onboarding docs get no transient state — no migration status, no "currently uses X", no dates. Anything that will be false in a month doesn't belong there.

---

## Framework Pitfalls (Always Apply)

- **`whenLoaded()`/`when()` omit the key** — the key is never present with `null`. Model such fields as optional (not `required`, no nullable union) in API schemas. When picking the first of a loaded collection, guard with `isEmpty() ? null : Resource::make(...)` — `Resource::make(null)` fatals on the first method call.

---

## Default Conventions for New Projects

> Use these when there is no existing pattern to follow. Do not impose these on legacy projects.

### Architecture

- **Services**: `readonly` classes with constructor injection. All business logic lives here. Controllers, jobs, and commands are thin layers that accept input and delegate to services.
- **Dependency injection**: Constructor injection everywhere — except in Laravel classes we extend (Artisan commands, framework-constructed jobs), where dependencies go in the `handle()` signature instead of a boilerplate `__construct` override.
- **Repositories**: Only for complex, multi-line queries. Extend `AbstractRepository` from `chiiya/laravel-utilities`. Simple Eloquent queries go directly where they're needed. When a private query helper in a service drops to a single caller, move the complete query — filters, eager loads, and the terminal `->get()` — into the repository and return the executed result, not a Builder.
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

### API Design

- Serialize timestamps as ISO 8601 UTC (`toIso8601String()`) — never `_local`/timezone-shifted variants; the frontend localizes.
- Query parameters for filtering/sorting use spatie/laravel-query-builder syntax (`filter[x]=value`) — never raw params like `?archived=1`. Split orthogonal concerns into separate filters.
- Prefer flat URLs (`/v2/items/{uuid}`) over nested ones when the child identifier is globally unique. Only nest when the parent is genuinely required for resolution.
- Group actions on the same resource into one multi-method controller; reserve invokable single-action controllers for truly standalone operations (webhooks, one-off commands).
- Reusable resource schemas live in their own JSON files and are `$ref`'d — never inlined as `$defs`. The item schema carries the `examples`; index/wrapper schemas only declare the `data` array.

### Filament

- **Filament closures bind parameters by name.** Unrecognized names fall through to `app()->make($type)` — `Builder $q` silently yields an empty Builder with no model. Always use the documented names (`$query`, `$record`, `$state`, `$value`, `$data`, `$get`, `$set`, `$livewire`) in evaluator-resolved closures.

### Testing

- **Pest** syntax (`it('...', function () { ... })`), not PHPUnit class syntax.
- Every feature and bugfix must have tests.
- Use factories — never create models manually in tests.
- Cover: happy path, validation failures, authorization, at least one edge case.
- Use `Queue::fake()`, `Notification::fake()`, `Event::fake()` for side effects.
- Test through real entry points (HTTP, jobs, commands) — don't write pseudo-unit tests that resolve a service from the container and assert side effects. When logic moves into a service, extend the existing tests of its callers instead.
- Cover Mailable rendering by triggering the real flow with `Mail::fake()` and calling `$mail->render()` inside the `Mail::assertSent()` closure — no standalone hand-constructed mail tests.

### Linting & Quality

- **chiiya/laravel-code-style** (ECS, Rector, PHP-CS-Fixer, Tlint) + **Larastan** at level 8.
- Run `just lint` and `just quality` (or the project's equivalent commands).
- GrumPHP handles pre-commit linting — do not skip it.

### Documentation

- Astro Starlight under `docs/`, following the Diataxis framework.
- OpenAPI specs for API documentation. Bruno collections for local API testing.
