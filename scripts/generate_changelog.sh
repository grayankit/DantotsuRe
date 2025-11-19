#!/bin/bash
set -e

echo "Generating changelog..."

# Get previous tag
PREV_TAG=$(git describe --tags --abbrev=0 HEAD^ 2>/dev/null || git rev-list --max-parents=0 HEAD)
REPO_URL="https://github.com/$GITHUB_REPOSITORY"

echo "Comparing from $PREV_TAG to HEAD"

# Category definitions
declare -A categories=(
    ["feat"]="### 🎉 New Features"
    ["fix"]="### 🛠️ Bug Fixes & Improvements"
    ["refactor"]="### 🔧 Refactors"
    ["style"]="### 🎨 Style Changes"
    ["perf"]="### 🚀 Performance Improvements"
    ["chore"]="### 🧹 Chores & Documentation"
)

# Collect commits by category
declare -A commits

while IFS= read -r line; do
    hash=$(echo "$line" | awk '{print $1}')
    msg=$(echo "$line" | cut -d' ' -f2-)
    
    # Determine commit type
    type=$(echo "$msg" | grep -oP '^(feat|fix|refactor|style|perf|chore|docs|build|ci)' || echo "other")
    
    # Normalize types
    [[ "$type" =~ ^(bug|improvement|patch)$ ]] && type="fix"
    [[ "$type" =~ ^(docs|build|ci)$ ]] && type="chore"
    
    # Add to appropriate category
    commits[$type]+="* [$hash]($REPO_URL/commit/$hash): $msg\n"
done < <(git log $PREV_TAG..HEAD --pretty=format:'%h %s')

# Write CHANGELOG.md
echo "" > CHANGELOG.md

for type in feat fix refactor style perf chore; do
    if [[ -n "${commits[$type]}" ]]; then
        echo "${categories[$type]}" >> CHANGELOG.md
        echo -e "${commits[$type]}" >> CHANGELOG.md
    fi
done

echo "CHANGELOG.md generated"

# Generate Fastlane changelog (plain text for IzzyOnDroid)
mkdir -p fastlane/metadata/android/en-US/changelogs

awk '/^### 🎉 New Features/{flag=1; next}/^### 🔧 Refactors/{flag=0}flag' CHANGELOG.md \
    | sed -E 's/!\[[^]]*\]\([^)]*\)//g; s/\[[^]]*\]\([^)]*\)//g; s/^\*[[:space:]]+/-/; s/^\s+//; /^$/d' \
    > fastlane/metadata/android/en-US/changelogs/default.txt || true

echo "Fastlane changelog generated"

# Display changelog for debugging
echo "=== CHANGELOG.md ==="
cat CHANGELOG.md
echo ""
echo "=== Fastlane changelog ==="
cat fastlane/metadata/android/en-US/changelogs/default.txt || echo "No fastlane changelog"
