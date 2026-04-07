# agent-tooling

Shared Claude Code tooling for the team. Installs skills, conventions, and hooks to every developer's machine with one command.

## What's included

- **Skills** — `/review-code`, `/review-security`, `/generate-pr`, `/handoff`, `/session-summary`
- **CLAUDE.md** — Team conventions (code philosophy, architecture patterns, security rules) installed at `~/.claude/CLAUDE.md`, applying to all projects
- **Hooks** — SessionStart update checker

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
