# start — bind the session to a ticket

Reads the ticket, works out who to ask, and states plainly what context is missing.

The output that matters is **not** "ticket loaded". It is the gap summary in step 4 — the
moment the user can say "that's covered, I'll brief you" before any planning happens.

## Steps

### 1. Resolve the ticket

`clickup_get_task` with the ID or the ID from a pasted URL. It accepts custom IDs such as
`DEV-1234` directly.

Not found, or no permission → **stop and report.** Never fall back to a similarly-named task;
questions would land on a stranger's ticket.

### 2. Read what is already there

The description, the custom fields, **and the existing comments** via
`clickup_get_task_comments`. Follow threads where `reply_count > 0`.

Do not skip the comments. Half the missing context is usually already sitting in a thread
nobody re-read, and asking a question that was answered three weeks ago on the same ticket is
the fastest way to make this skill unwelcome.

### 3. Work out who to ask

Default to the task's creator — they wrote the ticket, so they own its gaps. Resolve them to a
user ID with `clickup_resolve_assignees` so the comment can be assigned rather than shouted
into the void.

If the creator is no longer the obvious owner (long-dormant ticket, someone else clearly
active in the thread), say so and ask.

If no user can be resolved, note it now rather than discovering it at posting time.

### 4. State the gap

Report, in plain terms:

- what the ticket **does** establish
- what it **does not** — the specific decisions someone will have to make to plan this
- anything the comments already answered that the description does not

Be concrete. "Scope is unclear" is useless; "the ticket says chapters unlock over time but not
whether the clock starts at enrolment or at course start" is a question someone can answer.

### 5. Activate the session rule

Say explicitly that from here on, clarification questions will carry an
**"Ask ⟨name⟩ on the ticket"** option alongside the substantive answers, and that choosing it
parks the question rather than sending it.

Then plan as normal.

## Common mistakes

| Mistake | Consequence |
|---|---|
| Skipping the existing comments | Asking something already answered on the same ticket |
| Reporting "ticket loaded" instead of the gap | The whole point of the workflow is lost |
| A vague gap summary | The user cannot tell which gaps they could close themselves |
| Not resolving the recipient now | Discovering at posting time that nobody can be assigned |
| Falling back to a similar task | Questions land on the wrong ticket, visible to the wrong people |
