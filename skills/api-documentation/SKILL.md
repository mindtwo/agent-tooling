---
name: api-documentation
description: "Sets up and writes API reference documentation using Redocly CLI and Bruno. Activates when creating or editing OpenAPI specs, bundling API docs, linting API descriptions, adding Bruno requests or environments, or when the user asks to document or test API endpoints."
license: MIT
metadata:
  author: local
allowed-tools: Bash(npm run:*), Bash(php artisan route:list:*), Bash(grep:*)
---

# API Documentation

## When to Apply

Activate this skill when:

- Creating or editing OpenAPI spec files in `docs/api/`
- Setting up the Redocly toolchain for the first time
- Linting or validating an OpenAPI description
- Bundling an OpenAPI spec for distribution or rendering
- Generating standalone HTML API documentation
- Adding Bruno requests, folders, or environments in `docs/bruno/`

---

## Toolchain Setup

Run this setup when `@redocly/cli` is not present inside `package.json`.

### 1. Install packages

Add to `devDependencies` in `package.json`:

```json
"@redocly/cli": "^2.20.4"
```

Add to the `scripts` block in `package.json`:

```json
"lint:api-docs": "redocly lint",
"build:api-docs": "redocly bundle",
"preview:api-docs": "redocly build-docs docs/api/spec.yaml --output public/docs/api/index.html"
```

Then run `npm install`.

### 2. Create `redocly.yaml`

Read `.claude/skills/api-documentation/templates/redocly.yaml` and copy it to the project root. No changes needed to start — the template includes sensible defaults.

**Key `redocly.yaml` sections:**

| Section | Purpose |
|---|---|
| `apis` | Named API aliases — lets you run `redocly lint main` instead of specifying the path |
| `extends` | Base ruleset: `minimal`, `recommended`, `recommended-strict`, or `spec` |
| `rules` | Override individual rule severities (`error`, `warn`, `off`) |
| `resolve` | Configure HTTP headers for private `$ref` URLs |

### 3. Directory structure

```
docs/
└── api/
    ├── spec.yaml              # Root spec — info, servers, tags, paths (inline), components
    └── schemas/               # Reusable JSON schemas, referenced via $ref from spec.yaml
        ├── error.json
        ├── meta.json
        ├── links.json
        ├── {resource}-index.json
        ├── {resource}-show.json
        ├── {resource}-request.json
        └── ...
```

Paths are defined inline in `spec.yaml`. Only request/response body schemas live in separate files under `schemas/` as JSON. Reference them with relative paths:

```yaml
$ref: "schemas/{resource}-index.json"
```

---

## Linting

Always lint before bundling to catch issues early.

```bash
# Lint all configured APIs (uses redocly.yaml)
redocly lint

# Lint a specific API alias
redocly lint main

# Lint with a specific ruleset (overrides redocly.yaml extends)
redocly lint --extends=recommended-strict

# Output formats for CI integration
redocly lint --format=github-actions
redocly lint --format=json

# Generate an ignore file to suppress known issues
redocly lint --generate-ignore-file
```

### Rulesets

| Ruleset | Use when |
|---|---|
| `minimal` | Existing APIs with lots of legacy issues — few error-level rules |
| `recommended` | Greenfield APIs — good balance of strictness |
| `recommended-strict` | All warnings become errors — use in CI for enforcement |
| `spec` | Pure OpenAPI spec compliance only |

### Useful lint rules to enforce

```yaml
rules:
  operation-operationId: error       # Every operation must have a unique ID
  operation-summary: error           # Every operation must have a summary
  no-unused-components: error        # No dead components in the spec
  paths-kebab-case: warn             # /kebab-case paths
  tag-description: warn              # Tags must have descriptions
  no-ambiguous-paths: error          # Catch path conflicts early
  no-http-verbs-in-paths: warn       # Avoid /getUser — use GET /user
```

---

## Bundling

Bundle resolves all `$ref` references into a single output file.

```bash
# Bundle using redocly.yaml config (recommended)
redocly bundle

# Bundle a specific API alias
redocly bundle main --output public/docs/api/bundle.yaml

# Bundle to JSON
redocly bundle main --output public/docs/api/bundle.json --ext json

# Fully dereference (inline all $refs — useful for tools that don't support $ref)
redocly bundle main --dereferenced --output public/docs/api/bundle.yaml

# Strip unused components from output
redocly bundle main --remove-unused-components --output public/docs/api/bundle.yaml

# Force output even when lint errors exist
redocly bundle main --force --output public/docs/api/bundle.yaml
```

### Bundle flags reference

| Flag | Description |
|---|---|
| `--output, -o` | Output file path (default: stdout) |
| `--ext` | Output format: `yaml`, `yml`, `json` |
| `--dereferenced, -d` | Inline all `$ref`s — no references in output |
| `--remove-unused-components` | Strip components not referenced anywhere |
| `--force, -f` | Output even when validation errors exist |
| `--keep-url-references, -k` | Preserve absolute URL references as-is |

---

## Build Docs (Standalone HTML)

Generate a self-contained HTML file for sharing or serving:

```bash
# Build standalone HTML from root spec
redocly build-docs docs/api/spec.yaml --output public/docs/api/index.html

# Build from a configured API alias
redocly build-docs main --output public/docs/api/index.html

# Set a custom page title
redocly build-docs main --output public/docs/api/index.html --title "My API"

# Disable Google Fonts (useful for offline/intranet use)
redocly build-docs main --output public/docs/api/index.html --disableGoogleFont
```

---

## Spec Structure

Paths are defined inline in `docs/api/spec.yaml`. Only request/response body schemas live in separate files under `docs/api/schemas/` as JSON.

### Before writing schemas

Always read the source files that define the contract before creating or editing a schema:

- **FormRequest** — read the `rules()` method for field names, types, validation constraints (`required`, `max`, `min`, `in`, `unique`, `nullable`), and any conditional rules. This directly maps to the JSON schema for the request body.
- **JsonResource** — read `toArray()` for the exact response field names and types. For collections, check whether the controller uses `->paginate()` (include `meta` + `links`) or `->get()` (data array only, no pagination wrapper).

### Adding a new endpoint

Add the path inline in `spec.yaml` under `paths:`, referencing any schemas via relative `$ref`:

```yaml
paths:
  /v1/users/{id}:
    get:
      summary: Find User
      operationId: get-v1-user
      tags:
        - users
      parameters:
        - in: path
          name: id
          schema:
            type: string
            format: uuid
          required: true
          description: UUID of the user
      responses:
        '200':
          description: OK
          content:
            application/json:
              schema:
                $ref: "schemas/user.json"
      security:
        - bearer: []
```

### Adding a new schema

Create a JSON file in `docs/api/schemas/`. Follow the naming of existing files — lowercase, hyphen-separated, suffixed with the context (`-index`, `-show`, `-request`):

```json
{
  "type": "object",
  "properties": {
    "data": {
      "type": "array",
      "items": {
        "$ref": "user.json"
      }
    },
    "meta": {
      "$ref": "meta.json"
    },
    "links": {
      "$ref": "links.json"
    }
  }
}
```

Reference it from `spec.yaml` with:

```yaml
$ref: "schemas/users-index.json"
```

---

## Cross-linking with the Documentation Site

If a Starlight documentation site also exists (`astro.config.js` is present at the project root), add an `externalDocs` field to `spec.yaml` so the API reference links back to the full docs:

```yaml
externalDocs:
  description: Full documentation
  url: https://your-project.test/docs
```

Use the `get-absolute-url` tool to resolve the correct scheme, domain, and port for the docs URL before adding it to the spec.

---

## Validation Workflow

Run lint before every bundle to catch issues early:

```bash
# Validate config file itself
redocly check-config

# Lint, then bundle if clean
redocly lint && redocly bundle
```

For CI (GitHub Actions), use the `github-actions` format for inline annotations:

```bash
redocly lint --format=github-actions
```

---

## Bruno (API Client)

Bruno is a Git-friendly, offline-first API client. Collections are stored as plain-text `.bru` files under `docs/bruno/` and committed to source control alongside the code.

### Directory structure

```
docs/bruno/
└── {Collection Name}/
    ├── bruno.json              # Collection metadata (name, version, ignore)
    ├── collection.bru          # Collection-level defaults (auth, headers)
    ├── environments/
    │   ├── Local.bru           # vars + vars:secret for local development
    │   ├── Stage.bru           # vars + vars:secret for staging
    │   └── Production.bru      # vars + vars:secret for production
    ├── auth/
    │   ├── folder.bru          # Folder-level overrides (auth: none for login requests)
    │   └── Login.bru
    └── {feature}/
        ├── folder.bru          # Folder-level auth/header overrides
        └── List {Feature}.bru
```

### `bruno.json`

Created once per collection. Defines the collection name and files to ignore:

```json
{
  "version": "1",
  "name": "{Collection Name}",
  "type": "collection",
  "ignore": ["node_modules", ".git"]
}
```

### `collection.bru`

Collection-level defaults inherited by all requests unless overridden. Read `.claude/skills/api-documentation/templates/bruno/collection.bru` and copy it to `docs/bruno/{Collection Name}/collection.bru`. Add project-specific headers as needed.

### Environment files

Each environment file declares public `vars` and lists secret variable names in `vars:secret`. Secret values are stored encrypted on the developer's machine and never written to disk — they can be safely committed.

Read `.claude/skills/api-documentation/templates/bruno/environments/Local.bru` and copy it to `docs/bruno/{Collection Name}/environments/Local.bru`. Extend `vars` with any non-sensitive config (tenant codes, feature flags) and add all credentials, tokens, and UUIDs to `vars:secret`.

**Rules for environment files:**
- Non-sensitive config (base URL, feature flags) goes in `vars`
- All credentials, tokens, and UUIDs go in `vars:secret`
- Never move a secret variable to `vars` — it will be written to disk

### Folder files (`folder.bru`)

Each subfolder needs a `folder.bru` that sets the display name, sort order (`seq`), and any folder-level auth overrides. Read `.claude/skills/api-documentation/templates/bruno/folder.bru` as a starting point.

```bru
# auth/folder.bru — disable bearer for login endpoints
meta {
  name: auth
  seq: 1
}

auth {
  mode: none
}
```

### Request files

Read `.claude/skills/api-documentation/templates/bruno/request.bru` as a starting point for GET requests.

```bru
meta {
  name: Create Resource
  type: http
  seq: 2
}

post {
  url: {{url}}/v1/resources
  body: json
  auth: inherit
}

body:json {
  {
    "name": "{{name}}"
  }
}
```

**Request conventions:**
- Always set `auth: inherit` unless the request explicitly must bypass auth (e.g. login endpoints)
- Use `{{url}}` from the environment for the base URL — never hardcode it
- Set `seq` in `meta` to control sort order within a folder

### Scripting (`bru` API)

Use `script:pre-request` and `script:post-response` blocks for automation:

```bru
script:pre-request {
  // Read a variable set by a previous request
  const token = bru.getVar('some_token');
  bru.setVar('requestBody', JSON.stringify({ token }));
}

script:post-response {
  const data = res.getBody();

  // Persist auth tokens back to the environment after login
  bru.setEnvVar('accessToken', data.access_token, { persist: true });
}
```

| API | Description |
|---|---|
| `bru.getVar(name)` | Read a collection-scoped variable (set by previous scripts) |
| `bru.setVar(name, value)` | Write a collection-scoped variable (not persisted to environment) |
| `bru.getEnvVar(name)` | Read the current environment variable |
| `bru.setEnvVar(name, value, { persist })` | Write to the current environment; `persist: true` saves it to disk |
| `res.getBody()` | Parsed response body |
| `res.getStatus()` | HTTP status code |

### Auth flow pattern

Place login requests in an `auth/` folder with `auth: none`. Use `script:post-response` to persist the token into the environment:

```bru
script:post-response {
  const data = res.getBody();
  bru.setEnvVar('accessToken', data.access_token, { persist: true });
}
```

If the API uses a multi-step login (e.g. exchanging a token from one service for another), use `bru.setVar()` to pass intermediate tokens between requests in the same session without persisting them to the environment file. All subsequent requests then inherit bearer auth from `collection.bru` automatically.

### Adding a new endpoint

1. Create a `.bru` file in the appropriate folder: `docs/bruno/{Collection Name}/{feature}/Verb Noun.bru`
2. Set `auth: inherit` and use `{{url}}` as the base
3. Add a `folder.bru` if the folder doesn't have one yet
4. If the response contains IDs or tokens needed by later requests, use `bru.setEnvVar(..., { persist: true })` in `script:post-response`

---

## Common Pitfalls

- **Missing `operationId`** — Required for code generation and deep-linking. Add `operation-operationId: error` to `rules`.
- **Circular `$ref`s** — Use `--dereferenced` only for output, never in source files. Keep source refs non-circular.
- **Bundling without linting first** — Always `redocly lint` before `redocly bundle`. Bundling with `--force` masks real problems.
- **`redocly.yaml` not at project root** — Redocly searches the current directory. Always run commands from the project root, or pass `--config`.
- **Unused components** — Add `no-unused-components: error` to keep the spec clean. Dead components accumulate quickly.
- **Forgetting `--remove-unused-components` on bundle** — The bundled output can include dead components unless this flag is set.
- **Single huge `spec.yaml`** — Use the `split` command or structure as multi-file from the start. Large single-file specs are hard to diff and review.
- **HTTP verbs in paths** — `/getUser` breaks REST conventions. Use `no-http-verbs-in-paths: warn` to catch this.
