# ask — send the parked questions

Turns the parked questions into **one** comment on the ticket.

One comment, not one per question: the reader gets a single notification and can answer
everything in one sitting. A trickle of separate comments fragments the thread and gets
answered late or not at all.

## Steps

### 1. Check there is something to send

No parked questions → say so and stop.

Drop any question that planning has since answered on its own. A question the reader does not
need to answer is worse than no question, because it costs their attention for nothing.

### 2. Draft the comment

Write in the **ticket's own language** — the one the description and existing comments use.
Matter-of-fact, and short: this is a request for someone's time.

The first line is a fixed heading from this table, in that same language. `pull` searches for
these exact strings, so pick one verbatim rather than inventing a wording:

| Language | Heading |
|---|---|
| German | `**Rückfragen zur Umsetzung**` |
| English | `**Implementation questions**` |

Then stably numbered questions:

```markdown
**Rückfragen zur Umsetzung**

1. Soll der Import Bestandsdaten überschreiben oder nur neue Datensätze anlegen?
   a) überschreiben   b) nur neue
   _Warum: entscheidet, ob wir eine Vorschau vor dem Schreiben brauchen._

2. Was passiert mit Zeilen, die die Validierung nicht bestehen?
   a) Import abbrechen   b) Zeile überspringen und protokollieren
   _Warum: bestimmt, ob ein Teil-Import ein gültiger Endzustand ist._
```

Three things per question, all required:

- **The question**, answerable without the codebase open.
- **Candidate options** where they exist. `1b` is far faster to answer than a paragraph, and
  it forces you to have thought the question through. Omit them only where the answer is
  genuinely open.
- **One line of why it matters.** The reader has none of your planning context. A question that
  reads as a detail to them may be the fork the whole plan rests on, and without the *why* they
  cannot tell which it is.

**The heading is load-bearing.** `pull` finds this comment again by that exact string. It is
not decoration and must not be edited away or translated ad hoc. If the ticket's language is
not in the table, add a row there in the same commit as the first use — `ask` and `pull` must
never disagree about what to look for.

### 3. Preview gate

**Show the full drafted comment and stop.** The user may:

- drop questions entirely
- trim the options on any question
- rewrite any wording, including the tone

Nothing posts before an explicit approval. This comment notifies a colleague and joins a
shared record; there is no editing it out of their inbox afterwards.

### 4. Post

`clickup_create_comment` with:

| Field | Value |
|---|---|
| `entity_type` | `"task"` |
| `entity_id` | the ticket ID |
| `comment_text` | the approved draft |
| `assignee` | the user ID resolved in `start` |
| `notify_all` | `false` |

`notify_all: false` is deliberate — one person is being asked, not the whole watcher list.

If no user could be resolved, post unassigned with `notify_all: true` and **say that is what
happened**, so the user knows nobody was singled out.

### 5. Report

Print the ticket link, list which questions went out, and state plainly which parts of the
plan are now waiting on answers. Then continue with everything that is not blocked.

## Common mistakes

| Mistake | Consequence |
|---|---|
| One comment per question | Fragmented thread, several notifications, late answers |
| Posting without the preview gate | An unreviewed question sits in a colleague's inbox |
| Omitting the *why* line | The reader cannot judge how much the answer matters |
| Editing or improvising the heading | `pull` can never find the comment again |
| Writing in your language instead of the ticket's | The reader has to translate a request for their time |
| Renumbering between drafts | Replies reference numbers that no longer mean the same thing |
| Sending questions planning already answered | Costs a colleague's attention for nothing |
