#!/usr/bin/env bash
# Fires on PreToolUse for Bash commands that add dependencies.
# Blocks composer require and npm/yarn install <package> from running autonomously.

set -euo pipefail

# Read JSON input from stdin
INPUT="$(cat)"
COMMAND="$(echo "$INPUT" | jq -r '.tool_input.command // ""')"

# Normalise whitespace
COMMAND="$(echo "$COMMAND" | tr -s ' ' | sed 's/^ //')"

should_block() {
    local cmd="$1"

    # composer require (adding new packages)
    # Allow: composer install, composer update, composer dump-autoload
    if echo "$cmd" | grep -qE '^composer require'; then
        return 0
    fi

    # npm install <package> or npm install --save
    # Allow bare: npm install (no args — installs from package.json)
    if echo "$cmd" | grep -qE '^npm (i |install |add )'; then
        # npm install with no package argument is fine
        if echo "$cmd" | grep -qE '^npm (i|install)$'; then
            return 1
        fi
        return 0
    fi

    # yarn add
    if echo "$cmd" | grep -qE '^yarn add'; then
        return 0
    fi

    # pnpm add
    if echo "$cmd" | grep -qE '^pnpm add'; then
        return 0
    fi

    return 1
}

if should_block "$COMMAND"; then
    echo "Adding dependencies requires explicit developer approval. Please ask before running: $COMMAND" >&2
    exit 2
fi

exit 0
