#!/usr/bin/env bash
set -uo pipefail

# Verifies that the current repository is one the ClickUp binding actually covers, and
# prints its human-readable name.
#
# Why this exists: the skill is installed globally, so it is live in every repo, while
# .claude/clickup-plans.json is committed per repo and gets copied around by hand. Copied
# between one customer's own repos that is correct and intended. Copied to a different
# customer it would publish this project's plans into another customer's document, with no
# error and no obvious symptom.
#
# Repos are identified by NORMALIZED GIT REMOTE, not directory name: directory names are
# arbitrary, and "app-teach" under a different owner is a different repository. Customers
# also live on different hosts (github.com/a/x, gitlab.com/b/y), so the host is part of the
# identity.
#
# Exit codes:
#   0  covered      — stdout is the repo's display name
#   1  NOT covered  — refuse to write; stderr explains
#   2  no binding   — run the setup workflow
#   3  no remote    — identity cannot be established; refuse rather than guess
#   4  unusable     — jq missing or config malformed
#
# Tests: clickup-plan-guard.test.sh

project_dir="${CLAUDE_PROJECT_DIR:-$PWD}"
config="$project_dir/.claude/clickup-plans.json"

if ! command -v jq >/dev/null 2>&1; then
    echo "clickup-plans: jq is required for the repo guard but was not found." >&2
    exit 4
fi

[[ -f "$config" ]] || exit 2

remote="$(git -C "$project_dir" remote get-url origin 2>/dev/null)"
if [[ -z "$remote" ]]; then
    echo "clickup-plans: no 'origin' remote, so this repository cannot be identified." >&2
    echo "Refusing to write rather than guessing which binding applies." >&2
    exit 3
fi

# Normalize every remote spelling of the same repo to host/owner/project:
#   git@github.com:vnrag/app-teach.git      -> github.com/vnrag/app-teach
#   https://user@github.com/vnrag/app-teach -> github.com/vnrag/app-teach
#   ssh://git@gitlab.com:22/a/b.git         -> gitlab.com/a/b
normalize_remote() {
    printf '%s' "$1" |
        sed -E \
            -e 's#^[a-z+]+://##' \
            -e 's#^[^/@]*@##' \
            -e 's#^([^:/]+):([0-9]+)/#\1/#' \
            -e 's#^([^:/]+):#\1/#' \
            -e 's#\.git/?$##' \
            -e 's#/+$##' |
        tr '[:upper:]' '[:lower:]'
}

current="$(normalize_remote "$remote")"

label="$(jq -r '.label // "this binding"' "$config" 2>/dev/null)" || {
    echo "clickup-plans: $config is not valid JSON." >&2
    exit 4
}

# Config entries are normalized too, so a hand-written "https://github.com/vnrag/x.git"
# still matches a remote recorded in ssh form.
name=""
while IFS=$'\t' read -r entry_remote entry_name; do
    [[ -n "$entry_remote" ]] || continue
    if [[ "$(normalize_remote "$entry_remote")" == "$current" ]]; then
        name="$entry_name"
        break
    fi
done < <(jq -r '.repos[]? | [.remote // "", .name // ""] | @tsv' "$config" 2>/dev/null)

if [[ -z "$name" ]]; then
    echo "clickup-plans: this repository is not covered by the ClickUp binding." >&2
    echo "  repository: $current" >&2
    echo "  binding:    $label" >&2
    echo "Refusing to write — publishing here would put this project's plans into another" >&2
    echo "customer's document. Run the setup workflow to bind this repository." >&2
    exit 1
fi

printf '%s\n' "$name"
