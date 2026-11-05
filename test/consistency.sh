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

if [ "$failures" -ne 0 ]; then
    echo "$failures check(s) failed"
    exit 1
fi
echo "All checks passed"
