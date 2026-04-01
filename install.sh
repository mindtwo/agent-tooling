#!/usr/bin/env bash
# agent-tooling installer / updater
# Usage: ./install.sh [install|update|status|uninstall]

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_DIR="$HOME/.claude"
SKILLS_DST="$CLAUDE_DIR/skills"
SKILLS_SRC="$REPO_DIR/skills"
CLAUDE_MD_DST="$CLAUDE_DIR/CLAUDE.md"
CLAUDE_MD_SRC="$REPO_DIR/templates/CLAUDE.base.md"
SETTINGS="$CLAUDE_DIR/settings.json"
HOOKS_SRC="$REPO_DIR/hooks.json"
BIN_DIR="$HOME/.local/bin"
BIN_LINK="$BIN_DIR/agent-tooling"
LAST_FETCH_FILE="$CLAUDE_DIR/.agent-tooling-last-fetch"

GREEN="\033[0;32m"
YELLOW="\033[1;33m"
RED="\033[0;31m"
BOLD="\033[1m"
RESET="\033[0m"

ok()   { echo -e "  ${GREEN}✓${RESET} $*"; }
warn() { echo -e "  ${YELLOW}!${RESET} $*"; }
err()  { echo -e "  ${RED}✗${RESET} $*"; }
info() { echo -e "  ${BOLD}→${RESET} $*"; }

# ── Prerequisites ────────────────────────────────────────────────────────────

check_prereqs() {
    local failed=0

    if [[ ! -d "$CLAUDE_DIR" ]]; then
        err "~/.claude/ not found. Is Claude Code installed?"
        failed=1
    fi

    if ! command -v jq &>/dev/null; then
        warn "jq not found. Run: brew install jq"
        failed=1
    fi

    if ! command -v git &>/dev/null; then
        err "git not found."
        failed=1
    fi

    [[ $failed -eq 0 ]]
}

# ── Skills ───────────────────────────────────────────────────────────────────

install_skills() {
    local changed=0

    # Back up any existing skills not from this repo on first install
    if [[ -d "$SKILLS_DST" && ! -f "$SKILLS_DST/.managed-by-agent-tooling" ]]; then
        local backup="$SKILLS_DST/.backup-$(date +%Y%m%d%H%M%S)"
        info "Backing up existing skills to $backup"
        cp -R "$SKILLS_DST" "$backup"
    fi

    mkdir -p "$SKILLS_DST"
    touch "$SKILLS_DST/.managed-by-agent-tooling"

    for skill_dir in "$SKILLS_SRC"/*/; do
        local skill_name
        skill_name="$(basename "$skill_dir")"
        local dst="$SKILLS_DST/$skill_name"

        if [[ ! -d "$dst" ]]; then
            cp -R "$skill_dir" "$dst"
            ok "Installed skill: $skill_name"
            changed=1
        elif ! diff -rq --exclude="*.DS_Store" "$skill_dir" "$dst" &>/dev/null; then
            cp -R "$skill_dir" "$dst"
            ok "Updated skill: $skill_name"
            changed=1
        fi
    done

    if [[ $changed -eq 0 ]]; then ok "Skills up to date"; fi
}

# ── CLAUDE.md ────────────────────────────────────────────────────────────────

install_claude_md() {
    if [[ ! -f "$CLAUDE_MD_DST" ]]; then
        cp "$CLAUDE_MD_SRC" "$CLAUDE_MD_DST"
        ok "Installed ~/.claude/CLAUDE.md"
    elif ! diff -q "$CLAUDE_MD_SRC" "$CLAUDE_MD_DST" &>/dev/null; then
        cp "$CLAUDE_MD_SRC" "$CLAUDE_MD_DST"
        ok "Updated ~/.claude/CLAUDE.md"
    else
        ok "~/.claude/CLAUDE.md up to date"
    fi
}

# ── Hooks ────────────────────────────────────────────────────────────────────

install_hooks() {
    if [[ ! -f "$HOOKS_SRC" ]]; then
        warn "hooks.json not found, skipping hooks installation"
        return 0
    fi

    # Ensure settings.json exists
    if [[ ! -f "$SETTINGS" ]]; then
        echo '{}' > "$SETTINGS"
    fi

    # Read existing hooks and new hooks, then merge arrays (deduplicate by command)
    local existing_hooks new_hooks merged

    existing_hooks="$(jq '.hooks // {}' "$SETTINGS")"
    new_hooks="$(jq '.hooks' "$HOOKS_SRC")"

    # For each event in new_hooks, merge with existing by concatenating and deduplicating
    # on the "command" field within each hook entry
    merged="$(jq -n \
        --argjson existing "$existing_hooks" \
        --argjson new "$new_hooks" '
        $existing * $new |
        with_entries(
            .value |= (
                if type == "array" then
                    # Each entry has a "hooks" array; merge and deduplicate by command
                    group_by(.matcher // "") |
                    map(
                        if length == 1 then .[0]
                        else
                            .[0] + {
                                "hooks": (
                                    [.[].hooks // []] | flatten |
                                    unique_by(.command)
                                )
                            }
                        end
                    )
                else . end
            )
        )
    ')"

    # Write merged hooks back into settings.json
    local tmp
    tmp="$(mktemp)"
    jq --argjson hooks "$merged" '. + {hooks: $hooks}' "$SETTINGS" > "$tmp"
    mv "$tmp" "$SETTINGS"
    ok "Merged hooks into ~/.claude/settings.json"
}

# ── Symlink ──────────────────────────────────────────────────────────────────

install_symlink() {
    mkdir -p "$BIN_DIR"

    if [[ -L "$BIN_LINK" && "$(readlink "$BIN_LINK")" == "$REPO_DIR/install.sh" ]]; then
        ok "Symlink up to date"
        return 0
    fi

    ln -sf "$REPO_DIR/install.sh" "$BIN_LINK"
    ok "Symlinked to $BIN_LINK"

    # Remind user to add ~/.local/bin to PATH if needed
    if [[ ":$PATH:" != *":$BIN_DIR:"* ]]; then
        warn "Add to your shell profile: export PATH=\"\$HOME/.local/bin:\$PATH\""
    fi
}

# ── Install ──────────────────────────────────────────────────────────────────

cmd_install() {
    echo -e "\n${BOLD}agent-tooling install${RESET}\n"

    check_prereqs || { echo ""; err "Fix the above issues and re-run."; exit 1; }

    install_skills
    install_claude_md
    install_hooks
    install_symlink

    echo -e "\n${GREEN}${BOLD}Done.${RESET} Run \`agent-tooling status\` to verify.\n"
}

# ── Update ───────────────────────────────────────────────────────────────────

cmd_update() {
    echo -e "\n${BOLD}agent-tooling update${RESET}\n"

    info "Pulling latest changes..."
    cd "$REPO_DIR"

    if ! git diff --quiet HEAD 2>/dev/null; then
        warn "Uncommitted local changes detected. Stashing before pull."
        git stash push -m "agent-tooling auto-stash before update"
    fi

    git pull --ff-only origin main

    cmd_install
}

# ── Status ───────────────────────────────────────────────────────────────────

cmd_status() {
    echo -e "\n${BOLD}agent-tooling status${RESET}\n"

    # Skills
    echo "Skills:"
    for skill_dir in "$SKILLS_SRC"/*/; do
        local skill_name
        skill_name="$(basename "$skill_dir")"
        local dst="$SKILLS_DST/$skill_name"

        if [[ ! -d "$dst" ]]; then
            err "Not installed: $skill_name"
        elif ! diff -rq --exclude="*.DS_Store" "$skill_dir" "$dst" &>/dev/null; then
            warn "Outdated: $skill_name (run \`agent-tooling update\`)"
        else
            ok "$skill_name"
        fi
    done

    # CLAUDE.md
    echo ""
    echo "CLAUDE.md:"
    if [[ ! -f "$CLAUDE_MD_DST" ]]; then
        err "Not installed: ~/.claude/CLAUDE.md"
    elif ! diff -q "$CLAUDE_MD_SRC" "$CLAUDE_MD_DST" &>/dev/null; then
        warn "Outdated: ~/.claude/CLAUDE.md (run \`agent-tooling update\`)"
    else
        ok "~/.claude/CLAUDE.md"
    fi

    # Hooks
    echo ""
    echo "Hooks:"
    if [[ ! -f "$SETTINGS" ]]; then
        err "~/.claude/settings.json not found"
    elif jq -e '.hooks' "$SETTINGS" &>/dev/null; then
        ok "Hooks configured in ~/.claude/settings.json"
    else
        warn "No hooks in ~/.claude/settings.json (run \`agent-tooling install\`)"
    fi

    # Git status
    echo ""
    echo "Updates:"
    cd "$REPO_DIR"

    # Fetch at most once per day
    local now fetch_ts=0
    now="$(date +%s)"
    [[ -f "$LAST_FETCH_FILE" ]] && fetch_ts="$(cat "$LAST_FETCH_FILE")"

    if (( now - fetch_ts > 86400 )); then
        git fetch origin main --quiet 2>/dev/null || true
        echo "$now" > "$LAST_FETCH_FILE"
    fi

    local behind
    behind="$(git rev-list --count HEAD..origin/main 2>/dev/null || echo 0)"
    if (( behind > 0 )); then
        warn "$behind commit(s) available. Run: agent-tooling update"
    else
        ok "Up to date with origin/main"
    fi

    echo ""
}

# ── Uninstall ────────────────────────────────────────────────────────────────

cmd_uninstall() {
    echo -e "\n${BOLD}agent-tooling uninstall${RESET}\n"

    read -r -p "  Remove installed skills, CLAUDE.md, and symlink? [y/N] " confirm
    [[ "$confirm" =~ ^[Yy]$ ]] || { info "Aborted."; exit 0; }

    # Remove skills installed by this tool
    for skill_dir in "$SKILLS_SRC"/*/; do
        local skill_name
        skill_name="$(basename "$skill_dir")"
        local dst="$SKILLS_DST/$skill_name"
        if [[ -d "$dst" ]]; then
            rm -rf "$dst"
            ok "Removed skill: $skill_name"
        fi
    done

    rm -f "$SKILLS_DST/.managed-by-agent-tooling"

    # Remove CLAUDE.md
    if [[ -f "$CLAUDE_MD_DST" ]]; then
        rm -f "$CLAUDE_MD_DST"
        ok "Removed ~/.claude/CLAUDE.md"
    fi

    # Remove symlink
    if [[ -L "$BIN_LINK" ]]; then
        rm -f "$BIN_LINK"
        ok "Removed $BIN_LINK"
    fi

    info "Note: hooks in ~/.claude/settings.json were left in place. Remove manually if desired."
    echo ""
}

# ── Entry point ──────────────────────────────────────────────────────────────

case "${1:-install}" in
    install)   cmd_install ;;
    update)    cmd_update ;;
    status)    cmd_status ;;
    uninstall) cmd_uninstall ;;
    *)
        echo "Usage: agent-tooling [install|update|status|uninstall]"
        exit 1
        ;;
esac
