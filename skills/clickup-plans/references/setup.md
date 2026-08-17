# setup — bind this repo to a ClickUp doc

Produces `.claude/clickup-plans.json`. Run this when the file is missing, or when the repo
should point somewhere else.

**The container page has no required name.** It is whatever page plans should be nested
under, chosen per project — `Plans`, `Konzepte`, `Specs / 2026`, anything, in any language.
Do not assume, and do not propose a name before seeing the doc's existing pages.

## Steps

### 1. Check for an existing binding

If `.claude/clickup-plans.json` exists, show the current `label` and the resolved doc URL,
and ask whether to rebind. Do not overwrite without an answer.

### 2. Resolve the doc

Accept either:

- **A pasted URL.** In `/{workspace}/docs/{doc_id}/{page_id}` — and equally in
  `/{workspace}/v/dc/{doc_id}/{page_id}` — the **first** ID after `/docs/` or `/v/dc/` is
  the doc, the second is a page. A URL with only one ID gives you the doc alone.
- **A name.** `clickup_search` with `filters.asset_types: ["doc"]`, narrowed by
  `filters.location.categories` (folder IDs) when the project's space or folder is known. Show
  the matches and let the user pick.

### 3. Pick the container page

`clickup_list_document_pages` on the doc with `max_page_depth: 1`. Present the top-level
pages and their children, and ask which one plans should live under.

If the user wants a new one, `clickup_create_document_page` with **empty content** and no
`parent_page_id` (top-level) or the chosen parent. Container pages in these docs are pure
containers — their content lives in sub-pages.

### 4. Resolve the conventions page

List the doc's pages and ask which one holds the plan-format conventions. **Do not search
for a fixed name** — a project's doc may call it anything, in any language.

If there is none, show the seed from `page-format.md` (everything below the `SEED CONTENT`
marker), ask for approval, then create it. Ask what to call it; `Konventionen` is a
reasonable default for a German doc, `Conventions` for an English one.

The seed is German and splits the two pages by audience and language. Before creating it, ask
whether that fits this project — an English-speaking client, or a team that wants one language
throughout, gets the seed translated or collapsed at this point. It is far cheaper to adapt
here than after twenty plans have been rendered from it.

Never skip this step. Every other workflow reads that page as the format contract, and
`publish` cannot render without it.

### 5. Collect the repositories

One binding often covers **several repos** — a backend and its frontend both implement the
same plan and publish into the same container. A single-repo project is equally normal; do not
invent a second entry.

Repos are identified by **normalized git remote**, not directory name: directory names are
arbitrary, projects live on different hosts, and a project name repeats across owners.
Start from `git remote get-url origin` in the current repo and ask which others belong to
the same binding.

### 6. Ask for the spec page name

What the developer-facing child page should be called. `Technical Specification` is a
reasonable default; anything else is fine, in any language, as long as it is recorded here —
every other workflow resolves the child page by this name.

### 7. Write the config

```jsonc
{
  "repos": [
    { "remote": "github.com/example-org/app-backend",  "name": "app-backend" },
    { "remote": "gitlab.com/example-org/app-frontend", "name": "app-frontend" }
  ],
  "doc_id": "abc12-28695",
  "container_page_id": "abc12-118815",
  "conventions_page_id": "abc12-140015",
  "spec_page_name": "Technical Specification",
  "label": "Example Client – Plans / 2026"
}
```

Identifiers, the repo list, and a human label. **No status, no page map, no active
pointer** — plans resolve live by listing the container, so there is nothing here that can
drift.

Verify with the repo guard — `scripts/clickup-plan-guard.sh` in the skill directory, path in
SKILL.md. It must exit 0 and print this repo's name. If it does not, the `repos` list is
wrong — fix it before finishing.

### 8. Hand off

Print the doc and container URLs, then tell the user what still needs committing:

- `.claude/clickup-plans.json` — the binding must be identical for everyone. Because it is
  committed and lists every repo the binding covers, it can be copied verbatim into those
  sibling repos; the guard refuses it anywhere else.
- `.gitignore` — needs `!.claude/clickup-plans.json` in the `.claude/*` allowlist, otherwise
  the binding is not shared and the skill works only for whoever set it up.

**The skill and its hook are not per-repo.** Both ship with `agent-tooling` and install
once into `~/.claude`; the repo contributes nothing but this config file. A colleague who
sees no publish nudge after finishing a plan has not installed or updated agent-tooling —
tell them to run `agent-tooling update`, not to copy files into the repo.

## If ClickUp is unreachable

`clickup_search` or `clickup_list_document_pages` failing with an auth error means the MCP
server is not connected. Tell the user to run `/mcp`, and stop. Do not write a partial
config — a config with unverified IDs is worse than none, because every later workflow will
trust it.
