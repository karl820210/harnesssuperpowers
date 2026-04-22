#!/usr/bin/env bash
# verify-adapters.sh — ensure .kiro/ adapter skills stay in sync with canonical skills/.
#
# Checks (for each .kiro/skills/*/SKILL.md that contains the adapter marker):
#   1) adapter front-matter 'description' field matches canonical
#   2) the canonical pointer path exists
#
# Exit codes:
#   0  all adapters in sync (or no adapters present)
#   1  at least one adapter is out of sync
#
# Usage: bash scripts/verify-adapters.sh

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$REPO_ROOT"

ADAPTER_MARKER='<!-- SUPERPOWERS_ADAPTER -->'
FAIL=0
CHECKED=0

extract_front_matter_field() {
    # extract_front_matter_field <file> <field>
    # Returns trimmed value of a `field: value` line inside the top YAML block.
    local file="$1"
    local field="$2"
    awk -v f="$field" '
        BEGIN { inblock=0 }
        /^---[[:space:]]*$/ { inblock = !inblock; next }
        inblock && $0 ~ "^"f"[[:space:]]*:" {
            sub("^"f"[[:space:]]*:[[:space:]]*", "", $0)
            print $0
            exit
        }
    ' "$file"
}

check_adapter() {
    local adapter_file="$1"
    CHECKED=$((CHECKED + 1))

    # Parse canonical pointer from line like: "> **Canonical**: `skills/<name>/SKILL.md`"
    local canonical_rel
    canonical_rel=$(grep -E '^\> \*\*Canonical\*\*:' "$adapter_file" | head -n1 \
        | sed -E 's/.*`([^`]+)`.*/\1/')
    if [ -z "$canonical_rel" ]; then
        echo "FAIL: $adapter_file — cannot find canonical pointer line" >&2
        FAIL=$((FAIL + 1))
        return
    fi

    if [ ! -f "$canonical_rel" ]; then
        echo "FAIL: $adapter_file — canonical file missing: $canonical_rel" >&2
        FAIL=$((FAIL + 1))
        return
    fi

    local adapter_desc canonical_desc
    adapter_desc=$(extract_front_matter_field "$adapter_file" description)
    canonical_desc=$(extract_front_matter_field "$canonical_rel" description)

    if [ "$adapter_desc" != "$canonical_desc" ]; then
        echo "FAIL: $adapter_file — description drift" >&2
        echo "  adapter  : $adapter_desc" >&2
        echo "  canonical: $canonical_desc" >&2
        FAIL=$((FAIL + 1))
        return
    fi
}

while IFS= read -r -d '' f; do
    if grep -Fq "$ADAPTER_MARKER" "$f"; then
        check_adapter "$f"
    fi
done < <(find .kiro/skills -name SKILL.md -print0 2>/dev/null || true)

if [ "$FAIL" -eq 0 ]; then
    echo "verify-adapters.sh: $CHECKED adapter(s) checked, all in sync"
    exit 0
else
    echo "verify-adapters.sh: $FAIL failure(s) in $CHECKED adapter(s)" >&2
    exit 1
fi
