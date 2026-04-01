#!/usr/bin/env bash
# Fires on SessionStart. Checks if agent-tooling has updates available.
# Fetches from origin at most once per day.

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
LAST_FETCH_FILE="$HOME/.claude/.agent-tooling-last-fetch"

# Only run if this is a git repo with a remote
cd "$REPO_DIR"
if ! git remote get-url origin &>/dev/null; then
    exit 0
fi

# Fetch at most once per day
now="$(date +%s)"
last_fetch=0
[[ -f "$LAST_FETCH_FILE" ]] && last_fetch="$(cat "$LAST_FETCH_FILE" 2>/dev/null || echo 0)"

if (( now - last_fetch > 86400 )); then
    git fetch origin main --quiet 2>/dev/null || true
    echo "$now" > "$LAST_FETCH_FILE"
fi

# Check how many commits behind we are
behind="$(git rev-list --count HEAD..origin/main 2>/dev/null || echo 0)"

if (( behind > 0 )); then
    echo "[agent-tooling] $behind update(s) available. Run: agent-tooling update"
fi

exit 0
