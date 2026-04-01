#!/usr/bin/env bash
# Fires on PostToolUse for Write (new file creation).
# Reads the tool input from stdin and checks new PHP/test files for convention issues.
# Returns additionalContext if something looks off.

set -euo pipefail

# Read JSON input from stdin
INPUT="$(cat)"

# Only act on PHP files
FILE_PATH="$(echo "$INPUT" | jq -r '.tool_input.file_path // ""')"
if [[ "$FILE_PATH" != *.php ]]; then
    exit 0
fi

ISSUES=()

# Determine project structure: module or standard
# A module project has app/<Module>/Services/ patterns
PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"
IS_MODULE_PROJECT=false
if find "$PROJECT_DIR/app" -maxdepth 3 -type d -name "Services" 2>/dev/null | grep -q "app/[A-Z]"; then
    IS_MODULE_PROJECT=true
fi

# Check 1: Service classes should live in a Services/ directory
if [[ "$FILE_PATH" == *Service.php ]]; then
    if [[ "$FILE_PATH" != */Services/* ]]; then
        ISSUES+=("Service class \`$(basename "$FILE_PATH")\` is not in a \`Services/\` directory.")
    fi
    # Services should be readonly
    if ! grep -q "readonly class" "$FILE_PATH" 2>/dev/null; then
        ISSUES+=("Service class should be declared \`readonly class\`.")
    fi
fi

# Check 2: Repository classes should live in Repositories/ and extend AbstractRepository
if [[ "$FILE_PATH" == *Repository.php ]]; then
    if [[ "$FILE_PATH" != */Repositories/* ]]; then
        ISSUES+=("Repository class \`$(basename "$FILE_PATH")\` is not in a \`Repositories/\` directory.")
    fi
    if ! grep -q "extends AbstractRepository" "$FILE_PATH" 2>/dev/null; then
        ISSUES+=("Repository class should extend \`AbstractRepository\` from chiiya/laravel-utilities.")
    fi
fi

# Check 3: Test files in a module project should be in app/{Module}/Tests/
if [[ "$FILE_PATH" == *Test.php || "$FILE_PATH" == */tests/* || "$FILE_PATH" == */Tests/* ]]; then
    if [[ "$IS_MODULE_PROJECT" == true ]]; then
        if [[ "$FILE_PATH" == */tests/Feature/* || "$FILE_PATH" == */tests/Unit/* ]]; then
            ISSUES+=("This appears to be a module project (nwidart/laravel-modules). Tests should live in \`app/{Module}/Tests/\`, not the root \`tests/\` directory.")
        fi
    fi
    # Check for Pest syntax (avoid PHPUnit class syntax)
    if grep -q "class.*extends.*TestCase" "$FILE_PATH" 2>/dev/null; then
        ISSUES+=("Use Pest function syntax (\`it('...', function() { ... })\`) instead of PHPUnit class syntax.")
    fi
fi

# Check 4: Enums should be in Enumerators/ (not Enums/)
if [[ "$FILE_PATH" == */Enums/* && "$FILE_PATH" == *.php ]]; then
    ISSUES+=("The team uses \`Enumerators/\` as the directory name for PHP enums, not \`Enums/\`.")
fi

# Output additionalContext if there are issues
if [[ ${#ISSUES[@]} -gt 0 ]]; then
    CONTEXT="Convention reminder for $(basename "$FILE_PATH"):"$'\n'
    for issue in "${ISSUES[@]}"; do
        CONTEXT+="- $issue"$'\n'
    done

    jq -n --arg ctx "$CONTEXT" '{
        "hookSpecificOutput": {
            "hookEventName": "PostToolUse",
            "additionalContext": $ctx
        }
    }'
fi

exit 0
