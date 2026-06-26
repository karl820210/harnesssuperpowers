#!/bin/bash
# Hook: run before every `git commit` in Claude Code.
# Exits 1 (blocks commit) if code files are staged but docs are not updated.
#
# Adjust DOC_PATTERN to match this project's actual documentation paths.

DOC_PATTERN='(DEV_NOTES|CHANGELOG)\.md$'

STAGED=$(git diff --cached --name-only 2>/dev/null)

# No staged files — let git handle the error itself.
[ -z "$STAGED" ] && exit 0

# Only config/doc/metadata changes — skip check.
CODE_STAGED=$(echo "$STAGED" | grep -vE '\.(md|txt|json|yaml|yml|gitignore|lock)$' | head -1)
[ -z "$CODE_STAGED" ] && exit 0

# Code is staged — verify docs are also staged.
DOCS_STAGED=$(echo "$STAGED" | grep -E "$DOC_PATTERN")
if [ -z "$DOCS_STAGED" ]; then
    echo "⚠️  Commit blocked: code changes staged but documentation not updated." >&2
    echo "   Update docs/DEV_NOTES.md and/or docs/CHANGELOG.md, stage them, then re-run commit." >&2
    exit 1
fi

exit 0
