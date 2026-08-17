---
name: clickup-interview
description: Use when planning or brainstorming from a ClickUp ticket that does not carry enough context — when a clarification question comes up that the ticket cannot answer, when questions need to go back to the colleague who wrote it, or when they have replied and planning should resume.
---

# ClickUp Interview

A ticket written by someone else rarely carries enough context to plan from. The gaps surface
mid-planning, one at a time, and both usual options are bad: guess and build the wrong thing,
or stop and chase the author, losing the session.

This skill adds a third route. Questions are **parked, not sent** — planning continues around
them, and they go out together as one comment.

The reader is a **colleague, not an external client**. Nothing here leaves the workspace.

## The session rule

Once `start` binds a ticket, **every clarification question put to the user carries an extra
option**:

```
Q: Should the import overwrite existing records, or only add new ones?
   1) overwrite
   2) only add new
   3) Ask ⟨name⟩ on the ticket      <- always present, alongside the real answers
```

`⟨name⟩` is the person `start` resolved as the ticket's owner.

This is the skill. The three workflows below are the machinery it needs.

**Keep the parked-question list visible** in each response while a ticket is bound. Nothing
enforces this rule — `AskUserQuestion` fires in every conversation, so there is no hook that
could catch it without becoming noise. Losing track of the rule as the session grows is the
most likely way this skill fails.

## Which workflow

| Situation | Read |
|---|---|
| Starting work from a ticket | `references/start.md` |
| Parked questions are ready to go out | `references/ask.md` |
| The colleague has replied | `references/pull.md` |

## The one rule

**Nothing is posted to a ticket without showing the full draft and getting approval.**

Ticket comments notify a colleague and become part of a shared record. Draft matter-of-fact,
**in the language the ticket is written in** — take it from the description and existing
comments rather than defaulting to German or English. At the preview gate the user may drop
questions, trim options and rewrite wording freely — **except the heading**, which `pull`
depends on to find the comment again.

## Red flags — stop

- About to post a comment without having shown the full draft
- About to send a question the moment it arises, instead of parking it
- Asking a question without saying *why it matters* — the reader has none of your context
- Treating a freeform reply as parsed without confirming the mapping
- Reposting a question that was already asked or already answered
- Continuing to plan on an assumption without saying which question it depends on

## Constraints

- **ClickUp tickets only.** For a ticket in Jira or anywhere without an MCP server, print the
  drafted text for manual paste rather than pretending it was sent.
- **No companion tasks are ever created.** The ticket already exists; linking is not creating.
- **No config, no local state.** The ticket lives in the conversation; `pull` takes a ticket
  ID when it runs in a later session.
