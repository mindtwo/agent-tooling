#!/usr/bin/env bash
set -uo pipefail

# Tests for clickup-plan-guard.sh — verifies the current repo is one the ClickUp binding
# actually covers.
#
# The failure this prevents: the skill is installed globally and therefore live in every
# repo, while .claude/clickup-plans.json is committed per repo and gets copied by hand.
# Copied between a customer's own repos that is correct; copied to a different customer it
# would publish one customer's plans into another's document, silently. Repos are identified
# by normalized git remote because directory names are arbitrary and collide across
# customers.
#
# Usage:  skills/clickup-plans/scripts/clickup-plan-guard.test.sh

GUARD="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/clickup-plan-guard.sh"

pass=0
fail=0

# $1 remote URL to set as origin ("" = no remote at all)
# $2 config JSON ("" = no config file)
# Echoes "<exit code>|<stdout>|<stderr>"
run_guard() {
    local remote="$1" config="$2" tmp out err rc
    tmp="$(mktemp -d)"
    mkdir -p "$tmp/.claude"
    git -C "$tmp" init -q 2>/dev/null
    [[ -n "$remote" ]] && git -C "$tmp" remote add origin "$remote"
    [[ -n "$config" ]] && printf '%s\n' "$config" >"$tmp/.claude/clickup-plans.json"
    out="$(cd "$tmp" && CLAUDE_PROJECT_DIR="$tmp" bash "$GUARD" 2>"$tmp/stderr")"
    rc=$?
    err="$(cat "$tmp/stderr")"
    rm -rf "$tmp"
    printf '%s|%s|%s' "$rc" "$out" "$err"
}

expect() {
    local desc="$1" want="$2" got="$3"
    if [[ "$got" == *"$want"* ]]; then
        printf '  ok   %s\n' "$desc"; ((pass++))
    else
        printf '  FAIL %s\n       want: %s\n       got:  %s\n' "$desc" "$want" "$got"; ((fail++))
    fi
}

VNR='{"repos":[{"remote":"github.com/vnrag/app-teach","name":"app-teach"},{"remote":"gitlab.com/vnrag/app-teach-frontend","name":"app-teach-frontend"}],"doc_id":"d","container_page_id":"c","conventions_page_id":"k","label":"VNR"}'

printf 'clickup-plan-guard\n'

# 1. SSH form of a bound remote passes and reports the human-readable repo name.
expect 'ssh remote in the list passes and prints its name' '0|app-teach|' \
    "$(run_guard 'git@github.com:vnrag/app-teach.git' "$VNR")"

# 2. Same repo cloned over HTTPS must normalize to the same identity.
expect 'https remote normalizes to the same identity' '0|app-teach|' \
    "$(run_guard 'https://github.com/vnrag/app-teach.git' "$VNR")"

# 3. Without the .git suffix, still the same repo.
expect 'missing .git suffix still matches' '0|app-teach|' \
    "$(run_guard 'https://github.com/vnrag/app-teach' "$VNR")"

# 4. A second repo of the SAME customer, on a different host, is legitimately covered.
expect 'a sibling repo on another host passes' '0|app-teach-frontend|' \
    "$(run_guard 'git@gitlab.com:vnrag/app-teach-frontend.git' "$VNR")"

# 5. THE case that matters: another customer's repo must be refused.
got="$(run_guard 'git@github.com:tempton/app-jet.git' "$VNR")"
expect 'a different customer is refused with exit 1' '1|' "$got"
expect 'refusal names the binding so the cause is obvious' 'VNR' "$got"

# 6. Same project name under a different owner is a different repo.
expect 'same project name, different owner, is refused' '1|' \
    "$(run_guard 'git@github.com:someoneelse/app-teach.git' "$VNR")"

# 7. No binding yet — distinct exit code so the caller can route to setup.
expect 'missing config exits 2' '2|' \
    "$(run_guard 'git@github.com:vnrag/app-teach.git' '')"

# 8. No git remote — cannot establish identity, so refuse rather than guess.
expect 'missing git remote exits 3' '3|' \
    "$(run_guard '' "$VNR")"

printf '\n%d passed, %d failed\n' "$pass" "$fail"
[[ $fail -eq 0 ]]
