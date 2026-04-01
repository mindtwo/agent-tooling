---
name: generate-pr
allowed-tools: Bash(git diff:*), Bash(git log:*), Bash(git branch:*), Bash(git status:*)
description: Generate a GitHub PR title and description from branch changes
argument: Optional context about the change (e.g., "this fixes the user registration bug reported by the client")
---

You're helping a developer write a clear, useful GitHub PR description.

Follow these steps:

1. Run `git branch --show-current` to get the branch name.
2. Run `git log master..HEAD --oneline` to see the commits.
3. Run `git diff master..HEAD --stat -- ':(exclude)composer.lock' ':(exclude)package-lock.json'` to see which files changed and how much.
4. Run `git diff master..HEAD -- ':(exclude)composer.lock' ':(exclude)package-lock.json'` to read the actual changes.
5. If the user provided an argument, use it as additional context when drafting the description.

6. From the changes, extract:
   - **What** changed (the code-level summary)
   - **Why** it changed (the purpose — infer from branch name, commits, and code)
   - **How to test** (what a reviewer should check)
   - **Migrations** (list any migration files with a one-line summary of what they do)
   - **Frontend changes** (note if any Blade/React/Vue files changed — reviewer may need to visually check)

7. Draft the PR:

   **Title**: Under 70 characters. Imperative mood. Describes what the PR does, not how.
   Examples: "Add two-factor authentication to login flow", "Fix order total rounding for EUR currency"

   **Description**: Use the format below.

8. Output the PR title and description as formatted markdown, ready to copy-paste into GitHub.

---

Output format:

---

**Title**: `<pr title here>`

---

**Description**:

## What

<1–3 bullet points describing the concrete changes>

## Why

<1–2 sentences on why this change is needed — the business or user reason>

## How to test

- [ ] <specific thing to check>
- [ ] <another thing to check>
- [ ] All tests pass (`php artisan test` or `./vendor/bin/pest`)
- [ ] Linting passes (`just lint` or equivalent)

## Migrations

<list migrations and what they do, or "No migrations" if none>

## Notes

<anything else a reviewer should know: breaking changes, deployment steps, feature flags, etc. Omit this section if there's nothing noteworthy>

---
