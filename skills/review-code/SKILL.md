---
name: review-code-local
allowed-tools: Bash(git diff:*), Bash(git status:*), Bash(git log:*), Bash(git blame:*), Bash(git show:*), Bash(git branch:*), Bash(git symbolic-ref:*), Bash(git show-ref:*), Bash(git rev-parse:*), Read
description: Code review local changes
argument: Optional focus area or context for the review (e.g., "focus on auth logic", "check error handling in the new API")
---

You're an experienced Laravel developer and software architect. Your task is to perform a thorough code review of all pending changes — committed on this branch and any uncommitted work in progress. Be critical and direct. The goal is to catch problems before they ship, not to validate the author. Do not flag security vulnerabilities — those are handled separately by `/review-security`.

**Be especially hard on over-engineering.** In practice, new code sometimes introduces unnecessary abstractions, interfaces, services, base classes, and design patterns that the task simply did not require. A solution that is twice as long as it needs to be is a real problem, not a minor style concern. If you see complexity that wasn't justified by the requirements, call it out firmly.

**Optional Focus**: If the user provided an argument, use it as the primary focus. Prioritise issues in that area and give more detailed analysis there, but still check for critical issues everywhere.

## Step 1: Gather context

Run the following in parallel:

1. `git branch --show-current`
2. Detect the base branch: run `git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's|refs/remotes/origin/||'`. If empty: use `develop` for `feature/*`/`bugfix/*`/`release/*` branches (if `develop` exists locally via `git show-ref --verify --quiet refs/heads/develop`), otherwise check for `main` then `master`.
3. `git diff ${BASE_BRANCH}..${BRANCH_NAME} -- ':(exclude)composer.lock' ':(exclude)package-lock.json'` — committed branch changes
4. `git diff HEAD -- ':(exclude)composer.lock' ':(exclude)package-lock.json'` — uncommitted (staged + unstaged) changes
5. `git log ${BASE_BRANCH}..HEAD --oneline` — commit history for context

If both diffs are empty, stop and inform the user.

For every file that appears in the diffs, read its **full current version** using the Read tool — not just the diff hunks. You need surrounding context to properly judge whether a solution is correct, appropriate, and complete.

## Step 2: Analyse the changes

Work through all four lenses. Be honest — an empty review is a red flag.

### 2a. Bugs, logic errors, and edge cases
- Does the logic correctly handle the expected inputs and states?
- Are edge cases handled: null values, empty collections, zero, negative numbers, concurrent requests, missing config?
- Is error handling consistent with the rest of the codebase? Are exceptions caught too broadly or too narrowly?
- Are there performance implications: N+1 queries, unbounded loops, missing database indexes, unnecessary eager loading?
- Could this break existing functionality or cause regressions in related features?

### 2b. Over-engineering and unnecessary complexity (YAGNI / KISS / DRY)

This is a primary focus area. Ask yourself: did the task actually require this complexity?

**Unnecessary abstractions**
- A new interface, abstract class, or trait introduced with only one concrete implementation and no stated plan for more
- A service class whose entire body is one or two Eloquent calls that could live directly in the controller or job
- A DTO or value object used in exactly one place — a plain array or direct assignment would be clearer
- A pipeline or multi-step class structure for what is effectively 3–4 lines of sequential code
- Wrapper or adapter classes around framework functionality that add no behaviour
- Helper or utility classes created for a single operation

**Premature generalisation**
- "Reusable" or "extensible" code designed for requirements that do not yet exist
- Generic/configurable structures written for a use case that only occurs once
- Config values, feature flags, or constants for things that have no realistic variation
- Base classes or traits extracting shared logic between two classes that don't actually share the same concept

**Doing more than was asked**
- The implementation introduces new patterns, layers, or conventions beyond what the task required
- Refactoring of surrounding code that wasn't part of the task
- Side features or behaviours added that weren't in the requirements
- Three or more similar items extracted into an abstraction when the original duplication was fine

**Violations of DRY in both directions** — duplication is bad, but premature DRY is worse. Three similar-looking lines of code are often better than an abstraction that obscures what's actually happening.

For each over-engineering issue found, consider: what is the simplest version of this code that correctly solves the problem? If the answer is significantly shorter or flatter than what was written, that gap is the issue.

### 2c. Completeness
Are there related files that should have changed but didn't?
- New model or changed schema without a corresponding migration
- New migration without updated `$fillable`, `$casts`, or enum values in the model
- New or changed route without a Form Request, or Form Request without proper `authorize()` and `rules()`
- New feature without tests, or changed logic with no test update
- API endpoint change without an OpenAPI spec update
- Config or environment variable added without updating `.env.example`
- Translatable strings added without updating translation files

### 2d. Code clarity
- Is the code readable without needing to trace through multiple layers? Would a junior dev understand it in 30 seconds?
- Are variable and method names clear and consistent with the surrounding codebase?
- Are there TODO/FIXME/HACK comments that should be resolved before merging?
- Does it match the conventions of the surrounding code (not introducing new patterns into an existing codebase)?
- Methods split into sub-methods each called exactly once with no clarity gain — sometimes a longer method is simpler than artificial decomposition.

## Step 3: Score and filter

For each issue found, assign a confidence score (0–100):
- 0: False positive or pre-existing issue not introduced by these changes
- 25: Possible issue, but context suggests it may be intentional or acceptable
- 50: Real issue, but minor or unlikely to cause problems in practice
- 75: Real issue that will likely be hit in practice and impacts quality or correctness
- 100: Confirmed bug or significant problem — will definitely cause issues

Over-engineering issues score based on severity of the added complexity:
- A new class, interface, or abstraction with no immediate justification → 75 (Warning)
- A minor unnecessary helper method or slight over-abstraction → 50–60 (Suggestion)
- A substantial new layer, pattern, or architecture not required by the task → 80–90 (Warning)

Filter out any issue scoring below 50.

Typical false positives to exclude:
- Pre-existing issues not touched by the current changes (note these separately instead)
- Nitpicks a senior engineer wouldn't raise in a real PR review
- Issues the linter, static analyser, or type checker already catches
- Intentional changes that look unusual but make sense in context

## Step 4: Report

Present findings in this format. Only include sections that have issues.

---

### Code Review

**Branch**: `<branch-name>`
**Focus**: <user's focus argument, if provided — omit line if none>

**Critical** (N issues)
> Must fix before merging.

1. **file.php:42** — Brief description

   Why it matters and suggested fix (with code snippet if helpful).

**Warning** (N issues)
> Should fix — includes significant over-engineering, logic issues, and important gaps.

1. **file.php:15** — Brief description

   Why it matters and suggested fix.

**Suggestions** (N issues)
> Code quality, simplification, completeness gaps — not blockers, but worth doing.

1. **file.php:28** — Brief description

   Explanation and suggestion.

**Pre-existing issues noticed** (N issues)
> Out of scope for this PR, but worth tracking.

1. **file.php:99** — Brief description

**Verdict**: PASS | PASS WITH WARNINGS | FAIL

- PASS: no Critical or Warning issues
- PASS WITH WARNINGS: Warning issues present, no Critical
- FAIL: one or more Critical issues

---

Or, if no issues found:

---

### Code Review

**Branch**: `<branch-name>`

No significant issues found. Code looks good.

Checked for: bugs, edge cases, performance, solution quality, completeness, code clarity.

**Verdict**: PASS

---
