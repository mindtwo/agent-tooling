# agent-tooling

Shared Claude Code tooling for the team. Installs skills, conventions, and hooks to every developer's machine with one command.

## What's included

- **Skills** — `/review-code`, `/review-security`, `/review-tests`, `/review-migration`, `/generate-pr`, `/generate-tests`, `/audit-routes`, `/handoff`, `/session-summary`
- **CLAUDE.md** — Team conventions (code philosophy, architecture patterns, security rules) installed at `~/.claude/CLAUDE.md`, applying to all projects
- **Hooks** — SessionStart update checker

## Install

```bash
# Prerequisites: Claude Code, git, jq (brew install jq)

git clone git@github.com:your-org/agent-tooling.git ~/code/agent-tooling
cd ~/code/agent-tooling
./install.sh
```

That's it. Skills are immediately available in any Claude Code session. Add `~/.local/bin` to your `PATH` for the `agent-tooling` command.

## Update

```bash
agent-tooling update
```

Or: when you start a Claude Code session you'll see a notice if updates are available.

## Commands

| Command | Description |
|---|---|
| `agent-tooling install` | First-time install (default) |
| `agent-tooling update` | Pull latest + reinstall |
| `agent-tooling status` | Show what's installed and if updates are available |
| `agent-tooling uninstall` | Remove everything installed by this tool |

## Contributing

To add or modify a skill, edit the relevant `skills/<name>/SKILL.md` file and open a PR. The skill will be distributed to the team on their next `agent-tooling update`.

Keep skills focused: one skill, one job.
