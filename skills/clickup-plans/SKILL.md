---
name: clickup-plans
description: Use when a plan or spec needs to reach ClickUp or come back from it — after finishing native Plan Mode or superpowers planning, when binding a repo to a ClickUp doc, when starting implementation from a published spec, or when colleagues have left review feedback on one.
---

# ClickUp Plans

Plans written in Claude Code land in gitignored markdown nobody reads. This skill
publishes them into ClickUp in the shape the team already reads, tracks status through
review and implementation, and folds colleague feedback back into the spec.

**ClickUp is the only copy.** There is no markdown mirror to keep in sync.

## Which workflow

| Situation | Read |
|---|---|
| No `.claude/clickup-plans.json`, or rebinding the repo | `references/setup.md` |
| A plan was just finalized (Plan Mode, or superpowers writing-plans) | `references/publish.md` |
| Starting or continuing implementation from a published spec | `references/implement.md` |
| Colleagues left feedback on a published spec | `references/review.md` |

Read exactly one. The workflows are self-contained and never call each other.

## Before any workflow

1. **Run the repo guard.** `scripts/clickup-plan-guard.sh` in this skill's own directory —
   `~/.claude/skills/clickup-plans/scripts/clickup-plan-guard.sh` for the team install, or
   `.claude/skills/clickup-plans/scripts/…` if the skill was vendored into a repo. It prints
   this repo's display name and exits 0 when the binding covers it. Anything else means
   **do not write**:

   | Exit | Meaning | Do |
   |---|---|---|
   | 0 | covered | continue; use the printed name for `Repositories` and PR labels |
   | 1 | not covered | stop and show stderr — the config belongs to another customer |
   | 2 | no binding | run `setup` |
   | 3 | no `origin` remote | stop; identity cannot be established |
   | 4 | jq missing / bad JSON | stop and report |

   Repos are identified by **normalized git remote**, not directory name — customers live on
   different hosts and project names repeat across owners. One binding covers several repos
   (a backend and its frontend), which is why exit 0 is normal in each of them.

2. **Read `.claude/clickup-plans.json`** for `doc_id`, `container_page_id`,
   `conventions_page_id` and `spec_page_name`.
3. **Read the live conventions page** (`conventions_page_id`) via
   `clickup_get_document_pages`. That page is the format contract, not
   `references/page-format.md` — the reference file is only the seed `setup` uses when the
   page does not exist yet. If the live page and the seed disagree, **the live page wins.**
4. **Resolve plans by listing, not by memory.** `clickup_list_document_pages` on
   `container_page_id` and match the title. There is no stored page map.

Nothing in this skill hardcodes a page name or a status label. The conventions page supplies
the status vocabulary and the page structure; the config supplies `spec_page_name`. A doc in
another language, or with a different structure, works without editing the skill.

## The one rule

**Every ClickUp write is preceded by a rendered preview and an explicit approval.**

These pages are read by colleagues and by the PM. Nothing in this skill mutates shared
state unattended — not a status flip, not a PR link, not a typo fix.

`update_document_page` defaults to `content_edit_mode: "replace"`, which **overwrites the
entire page**. Colleague feedback lives on those pages. So:

- Adding to a page (PR link, resolution note) → `content_edit_mode: "append"`.
- Touching the header → read the live page and write it back **in the same turn**, diff shown
  first. There is no etag; a narrow window is the only protection there is.

## Red flags — stop

- About to call `update_document_page` without having shown the content first
- About to use the default `replace` mode for something that could have been an `append`
- Rendering a page from `references/page-format.md` without having read the live
  conventions page
- Writing a status label from memory instead of the conventions page's status table
- Guessing whether a plan involves frontend instead of asking
- Writing a status change to the child page without changing the parent in the same turn
- Continuing after the guard exited non-zero

## Constraints worth knowing

- **Doc-page comments are invisible.** `clickup_create_comment` accepts `task`, `list`,
  `view` — not doc pages. Feedback only reaches you if reviewers write list items in the
  `Feedback` / `Review Feedback` sections. That is why those sections carry an instruction
  line; keep it.
- **The Claude desktop chat app** publishes the parent page only — it has no codebase, so it
  cannot write a technical spec page. If a parent exists without a child, that is why.
