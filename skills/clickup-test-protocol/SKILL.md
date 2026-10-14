---
name: clickup-test-protocol
description: Use when a ClickUp ticket is implemented and needs a test protocol (Testprotokoll) as a ticket comment — "Testprotokoll für SD-123", "write the test protocol", "document the testing on the ticket" — with one block per task or Definition of Done item and a screenshot of each change. Takes one or more ticket IDs.
---

# ClickUp Test Protocol

When a ticket is done, the reviewer and the client want to see *what* changed and *that* it
was tested, without opening the code. This skill turns a ticket's tasks and Definition of
Done into a German test protocol, backs each point with a screenshot of exactly the changed
area, and posts it as a ticket comment, **only after the user has reviewed and approved it**.

## The one rule

**Nothing is uploaded or posted before the user has seen the full draft with all screenshots
and explicitly approved it** ("apply", "post it", "ja, posten"). The approval covers that one draft;
any later change needs a new approval. Without it, stop after the draft.

Uploading attachments counts as posting: they show up on the ticket immediately.

## Workflow

Per ticket ID (`SD-…`, `DEV-…`):

1. **Load the ticket.** `clickup_get_task` with `include: ["description"]`, plus
   `clickup_get_task_comments`. Note the creator (default `z.K.` person) and their user ID.
2. **Extract test points.** Every item under *Aufgaben* and *Definition of Done* becomes a
   test point; merge items that describe the same change. Client to-dos (*Was wir vom Kunden
   brauchen*) and dependencies are not test points.
3. **Find the code.** `git branch -a | grep -i <id>`, `git log --all --oneline --grep=<id>`,
   and `gh pr list --search <id> --state all`. Check whether it is merged and into which
   branch. Fetch first; a local branch can be stale. The diff tells you which UI areas,
   mails, PDFs or texts changed, and that decides what to screenshot.
4. **Verify each test point** with the cheapest real evidence: run the related tests,
   read-only DB queries, the browser. A point you could not verify is written as
   **open**, never glossed over. Don't claim anything ("abgesichert durch Tests", "geprüft")
   that you didn't actually see happen.
5. **Take screenshots.** See `references/screenshots.md`. One screenshot per visible change,
   cropped to the changed area (only the hero changed → only the hero). Changed mail
   templates get a rendered preview with the changed values highlighted.
6. **Draft the comment** in the template from `references/template.md`, in German unless
   the user asks otherwise. Ask the user about anything you can't decide from the code:
   deploy target, `z.K.` person, findings outside the ticket's scope (mention or leave out).
7. **Preview.** Show the full comment text and every screenshot (embed the local image paths)
   and wait for explicit approval.
8. **Post.** For each screenshot: `clickup_request_attachment_upload` → upload with `curl -F`
   → take `url` from the response. Insert each as a **link**
   `📎 [Screenshot: 01-….jpg](<url>)`, not as `![](…)`: ClickUp doesn't render Markdown images
   from the API. Then `clickup_create_comment` once, with the final text. Mention people as
   `[@Name](#user_mention#<user_id>)`; this only works on create, not on update.
   Details in `references/template.md`.
9. **Check.** `clickup_get_task_comments` confirms the comment exists and the links are in
   it. Ask the user to open the ticket once.

## Red flags — stop

- About to upload or post without an explicit approval of the exact draft
- A block claims something you didn't verify (tests not run, CP not opened, deploy not checked)
- A screenshot shows something the user decided to leave out; crop or retake it
- Typing a password into a login form; ask the user to log in in the browser pane instead
- Screenshot of a whole page when only one section changed
- Embedding screenshots as `![](url)`; they won't render, so link them
