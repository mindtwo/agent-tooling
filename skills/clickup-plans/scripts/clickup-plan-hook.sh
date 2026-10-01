#!/usr/bin/env bash
set -uo pipefail

# PostToolUse hook — nudges Claude to publish a finished plan to ClickUp.
#
# Planning ends either in native Plan Mode (the ExitPlanMode tool) or in the superpowers
# brainstorming -> writing-plans chain. The latter has no tool call of its own, so the
# anchor there is the path it writes to.
#
# This hook emits CONTEXT ONLY — it never writes to ClickUp and never touches the repo.
# It is also STATELESS: it nudges every time, and the publish workflow decides
# create-vs-update by looking at ClickUp. That is what lets it stay this simple; re-running
# is always safe.
#
# Registered globally in agent-tooling's hooks.json, which install.sh merges into
# ~/.claude/settings.json — one install covers every repo. Tests: clickup-plan-hook.test.sh

# Parsing the payload needs jq. If it is missing, stay silent rather than erroring — a hook
# that fails loudly on every tool call is far worse than one that quietly does nothing.
command -v jq >/dev/null 2>&1 || exit 0

payload="$(cat)"

tool_name="$(jq -r '.tool_name // empty' <<<"$payload" 2>/dev/null)" || exit 0
[[ -n "$tool_name" ]] || exit 0

# Claude Code sets CLAUDE_PROJECT_DIR; fall back to the cwd in the payload, then to $PWD.
project_dir="${CLAUDE_PROJECT_DIR:-}"
if [[ -z "$project_dir" ]]; then
    project_dir="$(jq -r '.cwd // empty' <<<"$payload" 2>/dev/null)"
fi
[[ -n "$project_dir" ]] || project_dir="$PWD"

is_plan_event() {
    case "$tool_name" in
        ExitPlanMode)
            return 0
            ;;
        Write)
            local file_path
            file_path="$(jq -r '.tool_input.file_path // empty' <<<"$payload" 2>/dev/null)"
            # Match on directory segments so that a file merely named "Plans…" never counts.
            case "$file_path" in
                */docs/superpowers/plans/*|docs/superpowers/plans/*) return 0 ;;
                */.claude/plans/*|.claude/plans/*) return 0 ;;
            esac
            return 1
            ;;
    esac
    return 1
}

is_plan_event || exit 0

# A fresh clone has no binding yet. Onboard instead of sending the user into a workflow
# that would immediately fail.
if [[ -f "$project_dir/.claude/clickup-plans.json" ]]; then
    context="A plan was just finalized. Use the clickup-plans skill, publish workflow, to publish it to ClickUp. Show the rendered pages and wait for approval before writing anything."
else
    context="A plan was just finalized, but this repo has no ClickUp binding yet (.claude/clickup-plans.json is missing). Use the clickup-plans skill, setup workflow, first."
fi

jq -n --arg ctx "$context" \
    '{hookSpecificOutput: {hookEventName: "PostToolUse", additionalContext: $ctx}}'
