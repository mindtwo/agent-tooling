# pull — collect the answers and resume

Reads the replies, works out which answer belongs to which question, and resumes planning.

## Steps

### 1. Resolve the ticket and find the question comment

Take the ticket from the session, or as an argument when this runs in a later session.

`clickup_get_task_comments`, then find the comment opening with
**`Rückfragen zur Umsetzung`**.

If several exist, take the **most recent one with unanswered questions** and say which you
picked — a ticket can accumulate rounds, and silently reading the wrong round produces answers
to questions nobody asked.

### 2. Read the replies — both kinds

- `clickup_get_threaded_comments` on the question comment where `reply_count > 0`
- **and** the ticket's top-level comments posted after it

People reply both ways. Checking only the thread loses answers that were typed into the main
comment box, and those are invisible failures — you resume planning believing nothing came
back.

### 3. Match answers to questions, then confirm

Replies are freeform. `"1b, bei 2 würde ich sagen offen lassen"` has to become an answer to
question 1 and an answer to question 2.

**Show the mapping and ask the user to confirm it.** Do not proceed on a parse.

```
Nina antwortete:
  1 → b) pro Kapitel
  2 → bleiben offen ("würde ich sagen offen lassen")
  3 → keine Antwort

Stimmt diese Zuordnung?
```

Where a reply is ambiguous, say so rather than picking the likelier reading. An answer matched
to the wrong question is worse than an unanswered question, because nothing later will catch
it.

### 4. Handle the partial case

Partially answered is normal, not an error.

Report which questions are resolved and which are still open, then let the user choose:

- proceed on a stated assumption for the open ones — and record which part of the plan rests
  on it
- wait, and continue with the parts that do not depend on them

Never silently assume an answer to an unanswered question.

### 5. Close the loop

Post a short reply in the thread saying what was taken:

```markdown
Danke! Übernommen: Drip pro Kapitel (1), freigeschaltete Kapitel bleiben bei Abmeldung
offen (2). Frage 3 ist noch offen.
```

Same preview-and-approve gate as `ask`. This costs one line and means the colleague can see
their answer landed without asking anyone — the same discipline as feedback resolution in
`clickup-plans`.

### 6. Resume

Continue planning with the answers in hand. Revisit anything that was drafted around the gap:
an answer that arrives late often invalidates an assumption made earlier in the session, and
that is exactly the part nobody re-checks.

## Common mistakes

| Mistake | Consequence |
|---|---|
| Reading only threaded replies | Top-level answers are silently missed |
| Accepting the parse without confirmation | An answer attached to the wrong question, uncaught |
| Picking the likelier reading of an ambiguous reply | Same, with more confidence behind it |
| Assuming an answer to an unanswered question | The plan rests on something nobody said |
| Skipping the acknowledgement | The colleague cannot tell whether the answer was used |
| Not revisiting earlier drafting | The plan keeps an assumption the answer just invalidated |
