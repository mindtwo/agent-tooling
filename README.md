# agent-tooling

Shared Claude Code tooling for the team. Installs skills, conventions, and hooks to every developer's machine with one command.

## What's included

- **Skills** — `/review-code`, `/review-security`, `/generate-pr`, `/handoff`, `/session-summary`, `/clickup-plans`, `/clickup-interview`
- **CLAUDE.md** — Team conventions (code philosophy, architecture patterns, security rules) installed at `~/.claude/CLAUDE.md`, applying to all projects
- **Hooks** — SessionStart update checker, and a PostToolUse nudge to publish finished plans to ClickUp

## ClickUp workflow

`clickup-plans` publishes finished plans into a ClickUp doc, tracks their status through
review and implementation, and folds colleague feedback back into the spec.
`clickup-interview` parks clarification questions during planning and sends them to the
ticket author as one comment.

Both are installed globally — a repo opts in with a single committed
`.claude/clickup-plans.json`, written by the skill's `setup` workflow. A guard script
refuses to publish from any repo the binding does not list, so a config copied into an
unrelated project fails loudly instead of writing into someone else's document.

Skill-local shell scripts live in `skills/clickup-plans/scripts/`. Their tests are plain
bash and run standalone:

```bash
skills/clickup-plans/scripts/clickup-plan-guard.test.sh
skills/clickup-plans/scripts/clickup-plan-hook.test.sh
```

The PostToolUse hook only reaches these scripts via `install.sh`. The npx path installs
skills but no hooks, so plans there need publishing by invoking the skill directly.

## Install

### install.sh

**Prerequisites:** Claude Code, git, jq (`brew install jq`)

```bash
git clone git@github.com:mindtwo/agent-tooling.git ~/code/agent-tooling
cd ~/code/agent-tooling
./install.sh
```

Skills are immediately available in any Claude Code session. Add `~/.local/bin` to your `PATH` for the `agent-tooling` command.

### npx (via vercel-labs/skills)

If you use [vercel-labs/skills](https://github.com/vercel-labs/skills) for cross-agent skill management:

```bash
npx skills add https://github.com/mindtwo/agent-tooling
```

## Update (install.sh only)

```bash
agent-tooling update
```

Or: when you start a Claude Code session you'll see a notice if updates are available.

## Commands (install.sh only)

| Command | Description |
|---|---|
| `agent-tooling install` | First-time install (default) |
| `agent-tooling update` | Pull latest + reinstall |
| `agent-tooling status` | Show what's installed and if updates are available |
| `agent-tooling uninstall` | Remove everything installed by this tool |

## Contributing

To add or modify a skill, edit the relevant `skills/<name>/SKILL.md` file and open a PR. The skill will be distributed to the team on their next `agent-tooling update`.

Keep skills focused: one skill, one job.
