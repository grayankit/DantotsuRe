#!/bin/bash
set -e

# Helper function to convert hex to decimal
hex_to_decimal() {
    printf '%d' "0x${1#"#"}"
}

# Fetch latest tag by date
echo "Fetching latest tag..."
curl -s "https://api.github.com/repos/$GITHUB_REPOSITORY/tags" -o tags.json
TAGS=$(jq -r '.[].name' tags.json)

declare -a TAGS_WITH_DATES=()
for TAG in $TAGS; do
    TAG_DETAILS=$(curl -s "https://api.github.com/repos/$GITHUB_REPOSITORY/git/refs/tags/$TAG")
    OBJECT_URL=$(echo "$TAG_DETAILS" | jq -r '.object.url // empty')
    if [ -n "$OBJECT_URL" ]; then
        OBJECT_DETAILS=$(curl -s "$OBJECT_URL")
        DATE=$(echo "$OBJECT_DETAILS" | jq -r '.tagger.date // .committer.date // empty')
        if [ -n "$DATE" ]; then
            TAGS_WITH_DATES+=("$DATE $TAG")
        fi
    fi
done

LATEST_TAG=""
LATEST_DATE=""
for TAG_DATE in "${TAGS_WITH_DATES[@]}"; do
    TAG_DATE_TIME=$(echo "$TAG_DATE" | awk '{print $1}')
    TAG_NAME=$(echo "$TAG_DATE" | awk '{print $2}')
    if [[ -z "$LATEST_DATE" || "$TAG_DATE_TIME" > "$LATEST_DATE" ]]; then
        LATEST_DATE="$TAG_DATE_TIME"
        LATEST_TAG="$TAG_NAME"
    fi
done

echo "Latest tag: $LATEST_TAG"

# Get release notes
RELEASE_DATA=$(curl -s -H "Authorization: token $GITHUB_TOKEN" \
    "https://api.github.com/repos/$GITHUB_REPOSITORY/releases/latest")

RELEASE_NOTES=$(echo "$RELEASE_DATA" | jq -r '.body')

# Format release notes for Discord
features=$(echo "$RELEASE_NOTES" | grep -iE '^\*\s\[[a-f0-9]+\]\(.*\):\sfeat' | head -n 5)
fixes=$(echo "$RELEASE_NOTES" | grep -iE '^\*\s\[[a-f0-9]+\]\(.*\):\s(fix|bug|improvement|patch)' | head -n 5)
chores=$(echo "$RELEASE_NOTES" | grep -iE '^\*\s\[[a-f0-9]+\]\(.*\):\s(chore|docs|build|ci)' | head -n 5)

FORMATTED_NOTES=""
if [[ -n "$features" ]]; then
    FORMATTED_NOTES+="**🚀 Features**\n$features\n\n"
fi
if [[ -n "$fixes" ]]; then
    FORMATTED_NOTES+="**🐛 Fixes**\n$fixes\n\n"
fi
if [[ -n "$chores" ]]; then
    FORMATTED_NOTES+="**🛠 Chores**\n$chores\n\n"
fi

# Clean formatting
FORMATTED_NOTES=$(echo "$FORMATTED_NOTES" | sed -E 's/\): [^:]+:/) :/g')

# Determine webhook and ping based on release type
if [[ "$IS_BETA" == "true" ]]; then
    WEBHOOK_URL="$DISCORD_WEBHOOK_BETA_URL"
    PING_ROLE="$DISCORD_BETA_ROLE_PING"
    RELEASE_TYPE="Beta"
else
    WEBHOOK_URL="$DISCORD_WEBHOOK_RELEASE_URL"
    PING_ROLE="$DISCORD_STABLE_ROLE_PING"
    RELEASE_TYPE="Stable"
fi

# Build Discord payload
default_color="#1ac4c5"
embed_color=$(hex_to_decimal "$default_color")

discord_data=$(jq -nc \
    --arg field_value "$FORMATTED_NOTES

[📌 Full changelog](https://github.com/$GITHUB_REPOSITORY/releases/tag/$LATEST_TAG)" \
    --arg footer_text "Version $LATEST_TAG" \
    --arg timestamp "$(date -u +%Y-%m-%dT%H:%M:%S.000Z)" \
    --argjson embed_color "$embed_color" \
    --arg title "New $RELEASE_TYPE Release Dropped 🔥" \
    --arg ping "$PING_ROLE" \
    '{
        "content": $ping,
        "embeds": [
            {
                "title": $title,
                "color": $embed_color,
                "description": $field_value,
                "footer": {
                    "text": $footer_text
                },
                "timestamp": $timestamp
            }
        ]
    }')

echo "Sending release notification..."
curl -H "Content-Type: application/json" \
    -X POST \
    -d "$discord_data" \
    "$WEBHOOK_URL"

# Send download links
sleep 3
echo "Fetching download links..."

curl -s -H "Authorization: token $GITHUB_TOKEN" \
    "https://api.github.com/repos/$GITHUB_REPOSITORY/releases/latest" \
    | jq -r '.assets[].browser_download_url' \
    | sort > asset_links.txt

MESSAGE="**Dartotsu $LATEST_TAG Downloads:**\n\n"

while IFS= read -r LINK; do
    if [[ $LINK == *"arm64"* ]]; then
        MESSAGE+="• [Android_arm64]($LINK)\n"
    elif [[ $LINK == *"armeabi"* ]]; then
        MESSAGE+="• [Android_armeabi-v7a]($LINK)\n"
    elif [[ $LINK == *"Android_x86"* ]]; then
        MESSAGE+="• [Android_x86_64]($LINK)\n"
    elif [[ $LINK == *"Android_Universal"* ]]; then
        MESSAGE+="• [Android_Universal]($LINK)\n"
    elif [[ $LINK == *"iOS"* ]]; then
        MESSAGE+="• [iOS]($LINK)\n"
    elif [[ $LINK == *"Linux"* ]]; then
        MESSAGE+="• [Linux]($LINK)\n"
    elif [[ $LINK == *"macos"* ]]; then
        MESSAGE+="• [macOS]($LINK)\n"
    elif [[ $LINK == *"Installer"* ]]; then
        MESSAGE+="• [Windows]($LINK)\n"
    fi
done < asset_links.txt

echo "Sending download links..."
curl -H "Content-Type: application/json" \
    -X POST \
    -d "{\"content\": \"$MESSAGE\"}" \
    "$WEBHOOK_URL"

echo "Release notification sent successfully!"
