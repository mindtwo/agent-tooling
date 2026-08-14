# review — process colleague feedback into the spec

Reads the feedback sections of a published plan, turns each open item into a concrete spec
edit, and marks it resolved.

## Steps

### 1. Guard, resolve, read

Run the repo guard — `scripts/clickup-plan-guard.sh` in the skill directory, path in
SKILL.md. Non-zero → stop.

Read the conventions page for the status table, then resolve the plan as in `implement.md`
(list the container, match or ask). Read both pages with `content_format: "text/md"`.

Collect **unchecked** items — `- [ ]` — from the feedback section of both pages (the seed calls
them `Feedback` and `Review Feedback`; take the actual names from the conventions page). Both
pages in one pass: the PM's product objection and a developer's data-model objection often need
the same edit, and processing them separately produces two conflicting rewrites.

### 2. Stop early if there is nothing

No unchecked items → say so and stop. Do not re-read resolved items looking for work; the
checkbox is the record, and re-processing `- [x]` items rewrites decisions that were already
made.

If the page has no feedback section at all, the plan predates the convention. Offer to add
the section with its instruction line rather than editing feedback in silently.

### 3. Classify each item

| Kind | Handling |
|---|---|
| **Spec change** | Turn it into a concrete edit to a named section |
| **Question** | Answer it in the spec if the answer is knowable; otherwise move it to the open-questions section and say who needs to answer |
| **Out of scope** | Propose a row in the non-goals section (the seed calls it `Bewusste Nicht-Ziele`) with the reasoning — do not just decline it in chat, or the same objection returns next month |

**Do not silently reinterpret an item.** If a comment is ambiguous, say which reading you
took and why. The person who wrote it is not in the room.

### 4. Show the diff and wait

Print the affected sections before and after, plus the resolution note you will attach to
each item. Wait for approval. Feedback processing rewrites text colleagues argued about;
it is the last place to move fast.

### 5. Write

For each processed item, replace `- [ ]` with `- [x]` and append a one-line resolution:

```markdown
- [x] [⟨Name⟩] Abschnitt 3: Der Import sollte pro Mandant konfigurierbar sein → Konfiguration
      auf Mandantenebene ergänzt, globaler Default bleibt bestehen (§2.1)
```

The resolution is what makes this idempotent — re-running never re-processes the item, and the
reviewer can see their point landed without asking anyone.

Then write the updated spec sections. Read-modify-write in the same turn; diff already
shown.

### 6. Promote the status

Only when **every** item on **both** pages is `- [x]`, move to the **middle row** of the
conventions status table (reviewed, not yet implemented):

1. Parent header → that row's parent label; the last-updated line refreshed.
2. Parent page name → that row's emoji.
3. Child header → that row's child label.

Take all three strings from the conventions page, never from memory. All three in the same
turn. If any item is still open, leave the status where it is and say what remains — a plan
marked reviewed with open feedback is a plan someone will build from too early.

## Common mistakes

| Mistake | Consequence |
|---|---|
| Re-processing `- [x]` items | Already-settled decisions get rewritten |
| Processing only the parent page | Developer objections on the child are lost |
| Declining an out-of-scope item in chat only | The same objection returns; nothing was recorded |
| Promoting to the reviewed status with items still open | Someone implements a spec that is still under discussion |
| Reinterpreting an ambiguous comment silently | The reviewer's actual point never gets addressed |
