---
name: session-summary
description: Print a compact summary of what was done in this session
---

Produce a concise summary of this session. This is a lightweight alternative to `/handoff` — it prints to screen rather than writing a file, making it easy to paste into Slack or a PR comment.

## Format

Output exactly this structure (omit sections that don't apply):

---

**Session summary** — <date>

**Done**
- <concrete deliverable or change, one line each>

**Key decisions**
- <decision and brief reason — only include non-obvious choices>

**Open / next steps**
- <anything left incomplete or that needs follow-up>

---

## Rules

- Keep each bullet to one line
- "Done" entries should be concrete: files changed, features added, bugs fixed — not vague like "worked on auth"
- Only include "Key decisions" if something non-obvious was decided (architecture choice, trade-off made, something ruled out)
- Only include "Open / next steps" if there is actually follow-up work
- No preamble, no trailing remarks — just the formatted block above
