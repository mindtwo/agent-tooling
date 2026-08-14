# implement — build from a published spec

Reads a published plan, uses it as the working brief, and keeps its status and PR links
current as the work lands.

## Steps

### 1. Guard and resolve

Run the repo guard — `scripts/clickup-plan-guard.sh` in the skill directory, path in
SKILL.md. Non-zero → stop. Exit 0 prints this repo's display name; you need it for the PR
labels in step 5.

Read `.claude/clickup-plans.json`, read the conventions page for the status table, then
`clickup_list_document_pages` on `container_page_id`.

If the user named a plan, match it. Otherwise show the live list — the status emoji comes
back in the listing, so it doubles as a status overview:

```
🟡 Rechnungsexport
🟢 Rollen & Rechte
✅ SSO-Login
```

### 2. Read both pages

`clickup_get_document_pages` with `content_format: "text/md"` for the parent and the child
named `spec_page_name`.

If there is no child, the plan was published from Claude Desktop and has no technical spec
yet. Say so and offer to write one via `publish` — do not start implementing from the
product-facing parent alone.

Check `Repositories`. If it does not list the repo you are standing in, say so and ask
before continuing — either the plan's scope is wider than recorded, or you are in the wrong
repo for this work.

### 3. Check the gates before coding

Three things, all **before** the first edit:

- **The open-questions section on either page** (the seed calls them `Offene Fragen ans
  Produkt` and `Open Questions`). Surface every open item and get answers. These are blockers
  by construction; discovering them halfway through is how rework happens.
- **Status still at the first row of the conventions status table** (not yet reviewed). Warn
  that nobody has reviewed this yet and ask whether to proceed anyway. Proceeding is a
  legitimate choice — doing it unknowingly is not.
- **A `Design` line with no link yet.** Flag it before any frontend work starts.

### 4. Implement

Follow the spec page. Where reality contradicts the spec — a class moved, a
migration already exists, an assumption is wrong — **stop and report the contradiction**
rather than silently diverging. The spec is what colleagues reviewed; a divergence they
never saw is worse than a delay.

Real divergences get folded back into the page via `publish`'s update path.

### 5. Record PRs

As each PR opens, append its link to the parent's `PRs` line, **labelled with the repo name
the guard printed**:

```markdown
**PRs:** app-backend [#2094](…), app-frontend [#312](…)
```

The label is what keeps the trail readable when a plan spans repos — the backend often ships
a sprint before the frontend, and an unlabelled list of numbers from two hosts is unusable.

Use `content_edit_mode: "append"` where the shape allows it. A header rewrite needs
read-modify-write in one turn — read the page, splice the line, write it back, diff shown
first.

**Append, never replace.** A plan can ship across several PRs and several repos; dropping an
earlier link loses the trail.

### 6. Close it out

When the work is merged, move to the **final row** of the conventions status table:

1. Parent header → that row's parent label; the last-updated line refreshed.
2. Parent page name → that row's emoji, replacing the previous prefix.
3. Child header → that row's child label.

Take all three strings from the conventions page, never from memory.

**All three in the same turn.** A renamed page with a stale header, or a parent that moved
without its child, is worse than no status at all — the sidebar and the page disagree and
nobody knows which to trust.

**Only when the whole plan has shipped.** If `Repositories` lists a frontend that has not
merged yet, the plan is not implemented — leave the status alone and say what is outstanding.

Show the diff and get approval first, as always.

## Common mistakes

| Mistake | Consequence |
|---|---|
| Implementing past open questions | Rework, and a spec colleagues approved that no longer matches |
| Replacing the `PRs` line, or omitting the repo label | Earlier PRs vanish, or the trail becomes unreadable across repos |
| Marking implemented while a listed repo is unmerged | A half-shipped plan reads as done |
| Renaming the page without rewriting the header | Sidebar and page contradict each other |
| Diverging from the spec silently | Colleagues reviewed something that never shipped |
| Starting from the parent page when no child exists | Building from a product summary, not a spec |
