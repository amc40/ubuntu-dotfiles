#!/bin/bash
# Guards against install.sh components, the devcontainer feature options, the
# docs and the feature scenarios drifting apart. install.sh is the source of
# truth; adding or removing a component there makes this fail until the rest
# is updated.
set -uo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
INSTALL="$REPO_ROOT/dotfiles/install.sh"
FEATURE_DIR="$REPO_ROOT/devcontainer-feature/src/ubuntu-dotfiles"
FEATURE_JSON="$FEATURE_DIR/devcontainer-feature.json"
FEATURE_INSTALL="$FEATURE_DIR/install.sh"
SCENARIOS="$REPO_ROOT/devcontainer-feature/test/ubuntu-dotfiles/scenarios.json"
README="$REPO_ROOT/README.md"
failures=0

check() {
    local description="$1"
    shift
    if "$@" >/dev/null 2>&1; then
        echo "PASS: $description"
    else
        echo "FAIL: $description"
        failures=$((failures + 1))
    fi
}

components="$("$INSTALL" --list-components 2>/dev/null)"
check "install.sh lists components" test -n "$components"

agents="$(jq -r '.options.agent.enum[] | select(. != "none")' "$FEATURE_JSON")"

for component in $components; do
    check "$component: has an install_$component function" grep -q "^install_$component()" "$INSTALL"
    check "$component: documented in README" grep -q "^|.*\`$component\`" "$README"

    if grep -qx "$component" <<< "$agents"; then
        check "$component: selectable via the feature's agent option" true
        continue
    fi

    # Non-agent components must be switchable from the feature via a boolean option.
    env_var="$(sed -n "s/^\[ \"\\\$\([A-Z_]*\)\" = \"true\" \] || skip=\"\\\$skip,$component\"\$/\1/p" "$FEATURE_INSTALL")"
    check "$component: feature install.sh maps an option to --skip" test -n "$env_var"
    option="$(jq -r --arg v "$env_var" '.options | keys[] | select(ascii_upcase == $v)' "$FEATURE_JSON")"
    check "$component: feature declares the $env_var option" test -n "$option"
    check "$component: option documented in README" grep -q "^|.*\`$option\`" "$README"
    check "$component: option disabled in a feature scenario" \
        jq -e --arg o "$option" '[.[].features["ubuntu-dotfiles"][$o]] | any(. == false)' "$SCENARIOS"
done

# The reverse direction catches removed components leaving options behind.
for option in $(jq -r '.options | keys[] | select(. != "agent")' "$FEATURE_JSON"); do
    env_var="$(tr '[:lower:]' '[:upper:]' <<< "$option")"
    mapped="$(sed -n "s/^\[ \"\$$env_var\" = \"true\" \] || skip=\"\$skip,\(.*\)\"\$/\1/p" "$FEATURE_INSTALL")"
    check "option $option: maps to an existing component" grep -qx "$mapped" <<< "$components"
done
for agent in $agents; do
    check "agent $agent: is an install.sh component" grep -qx "$agent" <<< "$components"
done

# Skills are loaded by name from their directory, so a mismatch silently hides one.
SKILLS_DIR="$REPO_ROOT/dotfiles/.claude/skills"
for skill_file in "$SKILLS_DIR"/*/SKILL.md; do
    [ -e "$skill_file" ] || continue
    skill_dir="$(dirname "$skill_file")"
    skill="$(basename "$skill_dir")"
    frontmatter="$(sed -n '1{/^---$/!q};1,/^---$/p' "$skill_file" | sed '1d;$d')"
    check "skill $skill: frontmatter name matches its directory" \
        grep -qx "name: $skill" <<< "$frontmatter"
    check "skill $skill: has a description" grep -q '^description: .\+' <<< "$frontmatter"
    # Relative links like references/x.md must resolve, or the agent follows a dead pointer.
    for link in $(grep -o '(references/[^)]*)' "$skill_file" | tr -d '()'); do
        check "skill $skill: $link exists" test -f "$skill_dir/$link"
    done
done

# Subagents are loaded by name, so a mismatch with the filename silently hides one.
for agent_file in "$REPO_ROOT"/dotfiles/.claude/agents/*.md; do
    [ -e "$agent_file" ] || continue
    subagent="$(basename "$agent_file" .md)"
    frontmatter="$(sed -n '1{/^---$/!q};1,/^---$/p' "$agent_file" | sed '1d;$d')"
    check "subagent $subagent: frontmatter name matches its filename" \
        grep -qx "name: $subagent" <<< "$frontmatter"
    check "subagent $subagent: has a description" grep -q '^description: .\+' <<< "$frontmatter"
done

# Code patterns are read as a rubric by pattern-reviewer, so the fields it relies on
# must be present and well-typed; prose in the body is free-form.
PATTERNS_DIR="$SKILLS_DIR/code-patterns/patterns"
FIXTURES_DIR="$REPO_ROOT/test/fixtures/patterns"

PATTERN_SCHEMA="$SKILLS_DIR/code-patterns/references/pattern.schema.json"
SCRATCH="$(mktemp -d)"
trap 'rm -rf "$SCRATCH"' EXIT

# The schema holds the field rules; the filename match is the one rule JSON Schema
# cannot express. check-jsonschema reads YAML directly, which avoids depending on
# whichever yq the machine happens to have.
pattern_frontmatter() {
    local frontmatter
    frontmatter="$SCRATCH/$(basename "$1" .md).yaml"
    sed -n '1{/^---$/!q};1,/^---$/p' "$1" | sed '1d;$d' > "$frontmatter"
    echo "$frontmatter"
}

pattern_name_matches() {
    grep -qx "name: $(basename "$1" .md)" "$(pattern_frontmatter "$1")"
}

pattern_matches_schema() {
    uvx check-jsonschema@0.39.0 --schemafile "$PATTERN_SCHEMA" "$(pattern_frontmatter "$1")"
}

validate_pattern() { pattern_name_matches "$1" && pattern_matches_schema "$1"; }

# check-jsonschema exits 1 for every failure, including a missing file or a uvx that
# cannot fetch it, so a bare "it failed" would let a broken toolchain pass the negative
# checks. Requiring the specific schema error proves the schema is what rejected it.
rejected_by_schema_with() {
    local expected="$1" output
    output="$(pattern_matches_schema "$2" 2>&1)" && return 1
    grep -qF -- "$expected" <<< "$output"
}

rejects() { ! "$@"; }

check "pattern validator accepts a well-formed pattern" validate_pattern "$FIXTURES_DIR/valid-example.md"
check "pattern validator rejects missing-smells" \
    rejected_by_schema_with "'smells' is a required property" "$FIXTURES_DIR/missing-smells.md"
check "pattern validator rejects empty-not-a-violation" \
    rejected_by_schema_with "should be non-empty" "$FIXTURES_DIR/empty-not-a-violation.md"
check "pattern validator rejects unknown-key" \
    rejected_by_schema_with "Additional properties are not allowed" "$FIXTURES_DIR/unknown-key.md"
# This fixture is schema-valid, so only the filename rule can reject it.
check "name-mismatch fixture is valid against the schema" pattern_matches_schema "$FIXTURES_DIR/name-mismatch.md"
check "pattern validator rejects name-mismatch by filename" rejects pattern_name_matches "$FIXTURES_DIR/name-mismatch.md"
# An unrelated failure must not be mistaken for the expected rejection.
check "a different failure is not mistaken for the expected schema error" \
    rejects rejected_by_schema_with "Additional properties are not allowed" "$FIXTURES_DIR/missing-smells.md"

check "code-patterns skill has at least one pattern" compgen -G "$PATTERNS_DIR/*.md"
for pattern_file in "$PATTERNS_DIR"/*.md; do
    [ -e "$pattern_file" ] || continue
    check "pattern $(basename "$pattern_file" .md): front matter is well-formed" validate_pattern "$pattern_file"
done

if [ "$failures" -ne 0 ]; then
    echo "$failures check(s) failed"
    exit 1
fi
echo "All checks passed"
