# publish — put a finished plan into ClickUp

Runs after planning: native Plan Mode, or the superpowers brainstorming → writing-plans
chain. Creates or updates a two-page tree.

## Steps

### 1. Guard, config, contract

Run the repo guard — `scripts/clickup-plan-guard.sh` in the skill directory, path in
SKILL.md. Non-zero → stop. Exit 0 prints this repo's display name; keep it for step 5.

Read `.claude/clickup-plans.json` for `container_page_id`, `conventions_page_id` and
`spec_page_name`.

Read the live conventions page with `clickup_get_document_pages`,
`content_format: "text/md"`. **Render from that page**, not from
`references/page-format.md`. If it is gone, say so and run `setup` — do not fall back to
the seed silently, or the format quietly forks.

**Take the status labels from that page's status table.** Do not write a status string from
memory; the team can change the vocabulary there, and the page is the contract.

### 2. Get the plan

Either the plan text from `ExitPlanMode` in the conversation, or the markdown file just
written under `docs/superpowers/plans/` or `.claude/plans/`. Ask which plan is meant if
more than one is in play.

### 3. Create or update?

`clickup_list_document_pages` on `container_page_id`, `max_page_depth: 1`. Match by title,
ignoring the status emoji prefix.

- **No match** → create path.
- **Match** → update path. Say which page you matched and let the user correct you before
  writing; a wrong match overwrites someone's spec.
- **Ambiguous** → ask. Never guess between two similar titles.

### 4. Frontend and the design link

Scan the plan for frontend involvement. Look for the markers this project actually uses —
view and asset paths (`resources/views`, `resources/js`, `src/`), template and framework names
(Blade, Inertia, Livewire, Vue, React, Tailwind), and words describing something a user sees
("component", "screen", "form", "UI").

**Ask; do not conclude.** Report what you found — "this mentions Inertia pages and Tailwind
classes, so I read it as frontend-touching" — and let the user confirm. A wrong yes leaves a
dead placeholder on the page; a wrong no silently drops the design step.

If it is frontend, offer three choices:

1. paste an existing URL — Figma, a claude.ai/design project, or a published Artifact
2. generate a mockup now as a published Artifact and link it
3. leave the placeholder the conventions page prescribes for a pending link

If it is not frontend, **omit the `Design` line entirely.**

### 5. Render

Build both pages per the conventions page, at its **first status** (the "just published,
not yet reviewed" row of the status table).

- **Parent.** Product-facing: what this is, why, what is deliberately excluded, what it
  costs. It must be readable by a PO who has never seen the codebase.
- **Child**, named `spec_page_name` from the config. Developer-facing: affected files and
  classes, data model, migrations, test cases. Decisions carry their reasoning, not just
  their outcome.

Fill `Repositories` with **every repo this plan touches**, using the display names from the
config — not just the one you are standing in. A plan that adds an API and the UI that
consumes it belongs to both, and naming only one hides half the work. Ask if it is unclear.

Fill `Ticket` if the plan came from one — the conversation usually knows, otherwise ask. No
ticket → omit the line entirely.

Fill the header's last-updated line with today's date and the git user name
(`git config user.name`). Use whatever that line is called on the conventions page; the seed
calls it `Aktualisiert`.

### 6. Show it and wait

**Print the full rendered markdown of both pages and stop.** No write happens before an
explicit approval. This is not a formality — these pages are read by the PM and by
colleagues, and a `replace` write cannot be undone from here.

### 7. Write

**Create path:**

1. `clickup_create_document_page` — parent under `container_page_id`, name prefixed with the
   first status's emoji from the conventions table.
2. `clickup_create_document_page` — `spec_page_name` with `parent_page_id` set to the new
   parent.
3. Fill the parent's `**Related:**`-equivalent link once the child ID is known.

**Update path:**

1. `clickup_get_document_pages` on both pages, immediately before writing.
2. **Preserve, do not regenerate:** every `Feedback` / `Review Feedback` item including its
   checkbox state, the `PRs` line, and the current status. These carry work that did not
   come from the plan.
3. Replace only the spec sections.
4. `clickup_update_document_page` with the merged content.

### 8. Link back to the ticket

Only when a `Ticket` was set, and **only on the create path** — a plan is published once;
re-publishing an update must not notify the ticket again.

Post **one** comment on the task with `clickup_create_comment`, `entity_type: "task"`, linking
the plan page. Write it in the ticket's own language, and show the draft first, like any other
write:

```markdown
Spezifikation veröffentlicht: [⟨Plantitel⟩](https://app.clickup.com/…)
```

**Never create a task.** If the plan has no ticket, there is nothing to link — do not invent
one to hold the link.

### 9. Report

Print both page URLs, and the ticket link if one was set.

## Common mistakes

| Mistake | Consequence |
|---|---|
| Rendering from the seed instead of the live conventions page | Format forks; the team's edits to that page do nothing |
| Writing before showing the render | An unreviewed page goes out to the PM |
| Regenerating the whole page on update | Colleague feedback and PR links are erased |
| Guessing the frontend answer | Dead placeholder, or a missing design step nobody notices |
| Matching a similar title without asking | Overwrites the wrong spec |
| Writing status labels from memory | Silently overrides the conventions page the skill claims to follow |
| Listing only the current repo in `Repositories` | Half the plan's work becomes invisible |
| Using a language or section name the conventions page does not | The doc stops being uniform, and readers stop trusting the structure |
