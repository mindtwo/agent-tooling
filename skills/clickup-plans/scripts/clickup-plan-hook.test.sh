#!/usr/bin/env bash
set -uo pipefail

# Tests for clickup-plan-hook.sh — the PostToolUse hook that nudges Claude to publish
# a finished plan to ClickUp.
#
# The hook must be conservative: it fires on exactly two anchors (ExitPlanMode, and Write
# to a plan path) and must stay completely silent otherwise. A hook that fires on every
# Write in the repo would be worse than no hook at all, so that case is tested explicitly.
#
# Usage:  skills/clickup-plans/scripts/clickup-plan-hook.test.sh

HOOK="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/clickup-plan-hook.sh"

pass=0
fail=0

# Runs the hook with a temporary project dir and reports stdout.
#
# $1  "configured" | "unconfigured" — whether .claude/clickup-plans.json exists
# $2  stdin JSON payload
run_hook() {
    local state="$1" payload="$2" tmp
    tmp="$(mktemp -d)"
    mkdir -p "$tmp/.claude"
    if [[ "$state" == "configured" ]]; then
        printf '{"doc_id":"d","container_page_id":"c","conventions_page_id":"k","label":"l"}\n' \
            >"$tmp/.claude/clickup-plans.json"
    fi
    CLAUDE_PROJECT_DIR="$tmp" bash "$HOOK" <<<"$payload"
    rm -rf "$tmp"
}

# $1 description, $2 expected substring ("" = expect no output at all), $3 actual output
expect() {
    local desc="$1" needle="$2" actual="$3"
    if [[ -z "$needle" ]]; then
        if [[ -z "$actual" ]]; then
            printf '  ok   %s\n' "$desc"; ((pass++))
        else
            printf '  FAIL %s\n       expected no output, got: %s\n' "$desc" "$actual"; ((fail++))
        fi
    elif [[ "$actual" == *"$needle"* ]]; then
        printf '  ok   %s\n' "$desc"; ((pass++))
    else
        printf '  FAIL %s\n       expected substring: %s\n       got: %s\n' "$desc" "$needle" "$actual"
        ((fail++))
    fi
}

printf 'clickup-plan-hook\n'

# 1. Native Plan Mode: approving a plan must nudge publish.
expect 'ExitPlanMode emits the publish nudge' 'publish workflow' \
    "$(run_hook configured '{"tool_name":"ExitPlanMode","tool_input":{"plan":"# Plan\nDo the thing."}}')"

# 2/3. superpowers writing-plans has no tool call of its own, so the anchor is the
# path it writes to. Both plan locations must be recognised.
expect 'Write to docs/superpowers/plans emits the publish nudge' 'publish workflow' \
    "$(run_hook configured '{"tool_name":"Write","tool_input":{"file_path":"/repo/docs/superpowers/plans/2026-08-11-thing.md"}}')"

expect 'Write to .claude/plans emits the publish nudge' 'publish workflow' \
    "$(run_hook configured '{"tool_name":"Write","tool_input":{"file_path":"/repo/.claude/plans/thing.md"}}')"

# 4. A fresh clone has no binding yet — onboard instead of failing.
expect 'missing config emits the setup nudge instead' 'setup workflow' \
    "$(run_hook unconfigured '{"tool_name":"ExitPlanMode","tool_input":{"plan":"# Plan"}}')"

# 5. THE case that matters: everything else must be silent.
expect 'unrelated tool emits nothing' '' \
    "$(run_hook configured '{"tool_name":"Read","tool_input":{"file_path":"/repo/app/Models/User.php"}}')"

expect 'Write to an unrelated path emits nothing' '' \
    "$(run_hook configured '{"tool_name":"Write","tool_input":{"file_path":"/repo/app/Models/User.php"}}')"

# 6. A path that merely mentions "plans" is not a plan path.
expect 'Write to a lookalike path emits nothing' '' \
    "$(run_hook configured '{"tool_name":"Write","tool_input":{"file_path":"/repo/app/Services/PlansExporter.php"}}')"

# 7. Output must be valid JSON carrying the PostToolUse contract.
out="$(run_hook configured '{"tool_name":"ExitPlanMode","tool_input":{"plan":"# Plan"}}')"
if jq -e '.hookSpecificOutput.hookEventName == "PostToolUse"' <<<"$out" >/dev/null 2>&1; then
    printf '  ok   output is valid JSON with hookEventName PostToolUse\n'; ((pass++))
else
    printf '  FAIL output is valid JSON with hookEventName PostToolUse\n       got: %s\n' "$out"
    ((fail++))
fi

# 8. Without jq the hook cannot parse its input; it must degrade to silence, never error.
# macOS ships jq at /usr/bin/jq, so hiding it means an empty PATH, not a trimmed one.
tmp="$(mktemp -d)"; mkdir -p "$tmp/.claude" "$tmp/empty-bin"
printf '{}\n' >"$tmp/.claude/clickup-plans.json"
out="$(CLAUDE_PROJECT_DIR="$tmp" PATH="$tmp/empty-bin" /bin/bash "$HOOK" \
    <<<'{"tool_name":"ExitPlanMode","tool_input":{}}' 2>&1)"
rc=$?
rm -rf "$tmp"
if [[ $rc -eq 0 && -z "$out" ]]; then
    printf '  ok   degrades silently when jq is unavailable\n'; ((pass++))
else
    printf '  FAIL degrades silently when jq is unavailable\n       rc=%s out=%s\n' "$rc" "$out"
    ((fail++))
fi

printf '\n%d passed, %d failed\n' "$pass" "$fail"
[[ $fail -eq 0 ]]
