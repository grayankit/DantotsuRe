#!/bin/bash
set -e

# Helper function to fetch user details from GitHub
fetch_user_details() {
    local login=$1
    user_details=$(curl -s "https://api.github.com/users/$login")
    name=$(echo "$user_details" | jq -r '.name // .login')
    login=$(echo "$user_details" | jq -r '.login')
    avatar_url=$(echo "$user_details" | jq -r '.avatar_url')
    echo "$name|$login|$avatar_url"
}

# Helper function to convert hex color to decimal
hex_to_decimal() {
    printf '%d' "0x${1#"#"}"
}

# Contributor additional info (Discord handles, social profiles)
declare -A additional_info
additional_info["itsmechinmoy"]="\n Discord: <@523539866311720963>\n AniList: [itsmechinmoy](<https://anilist.co/user/6110204/>)"
additional_info["aayush262"]="\n Discord: <@918825160654598224>\n AniList: [aayush262](<https://anilist.co/user/5144645/>)"
additional_info["Ankit Grai"]="\n Discord: <@1125628254330560623>\n AniList: [bheshnarayan](<https://anilist.co/user/6417303/>)\n X: [grayankit01](<https://x.com/grayankit01>)"
additional_info["Shebyyy"]="\n Discord: <@612532963938271232>\n AniList: [ASheby](<https://anilist.co/user/5724017/>)"
additional_info["koxx12-dev"]="\n Discord: <@378587857796726785>)"

# Contributor color mapping
declare -A contributor_colors
default_color="#1ac4c5"
contributor_colors["aayush262"]="#ff7eb6"
contributor_colors["itsmechinmoy"]="#045b94"
contributor_colors["grayankit"]="#c51aa1"
contributor_colors["Shebyyy"]="#fff0cc"
contributor_colors["koxx12-dev"]="#1d1d1d"

# Get last SHA or first commit
if [ -f last_sha.txt ]; then
    LAST_SHA=$(cat last_sha.txt)
else
    LAST_SHA=$(git rev-list --max-parents=0 HEAD)
fi

echo "Commits since $LAST_SHA:"

# Get commit logs with special formatting
COMMIT_LOGS=$(git log $LAST_SHA..HEAD --pretty=format:"● %s ~%an [֍](https://github.com/$GITHUB_REPOSITORY/commit/%H)" --max-count=10)
COMMIT_LOGS="${COMMIT_LOGS//'%'/'%25'}"
COMMIT_LOGS="${COMMIT_LOGS//$'\n'/'%0A'}"
COMMIT_LOGS="${COMMIT_LOGS//$'\r'/'%0D'}"

echo "$COMMIT_LOGS"

# Set output for other jobs
echo "commit_logs=$COMMIT_LOGS" >> $GITHUB_OUTPUT

# Save current SHA for next run
echo "$GITHUB_SHA" > last_sha.txt

# Calculate recent commit counts
declare -A recent_commit_counts
echo "Debug: Processing COMMIT_LOG:"
echo "$COMMIT_LOGS"

while read -r count name; do
    recent_commit_counts["$name"]=$count
    echo "Debug: Commit count for $name: $count"
done < <(echo "$COMMIT_LOGS" | sed 's/%0A/\n/g' | grep -oP '(?<=~)[^[]*' | sort | uniq -c | sort -rn)

# Fetch contributors from GitHub
echo "Debug: Fetching contributors from GitHub"
contributors=$(curl -L \
  -H "Accept: application/vnd.github+json" \
  -H "X-GitHub-Api-Version: 2022-11-28" \
  "https://api.github.com/repos/$GITHUB_REPOSITORY/contributors")

echo "Debug: Contributors response:"
echo "$contributors"

# Sort contributors by recent commit count
sorted_contributors=$(for login in $(echo "$contributors" | jq -r '.[].login'); do
    user_info=$(fetch_user_details "$login")
    name=$(echo "$user_info" | cut -d'|' -f1)
    count=${recent_commit_counts["$name"]:-0}
    echo "$count|$login"
done | sort -rn | cut -d'|' -f2)

# Build developer list
developers=""
committers_count=0
max_commits=0
top_contributor_count=0
top_contributor_avatar=""
embed_color=$(hex_to_decimal "$default_color")

while read -r login; do
    user_info=$(fetch_user_details "$login")
    name=$(echo "$user_info" | cut -d'|' -f1)
    login=$(echo "$user_info" | cut -d'|' -f2)
    avatar_url=$(echo "$user_info" | cut -d'|' -f3)

    commit_count=${recent_commit_counts["$name"]:-0}
    
    if [ $commit_count -gt 0 ]; then
        # Determine top contributor(s)
        if [ $commit_count -gt $max_commits ]; then
            max_commits=$commit_count
            top_contributors=("$login")
            top_contributor_count=1
            top_contributor_avatar="$avatar_url"
            embed_color=$(hex_to_decimal "${contributor_colors[$name]:-$default_color}")
        elif [ $commit_count -eq $max_commits ]; then
            top_contributors+=("$login")
            top_contributor_count=$((top_contributor_count + 1))
            embed_color=$(hex_to_decimal "$default_color")
        fi

        # Get total commit count
        branch_commit_count=$(git log --author="$login" --author="$name" --oneline | awk '!seen[$0]++' | wc -l)

        # Add extra info if available
        extra_info="${additional_info[$name]}"
        if [ -n "$extra_info" ]; then
            extra_info=$(echo "$extra_info" | sed 's/\\n/\n- /g')
        fi

        developer_entry="◗ **${name}** ${extra_info}
  - Github: [${login}](https://github.com/${login})
  - Commits: ${branch_commit_count}"

        if [ -n "$developers" ]; then
            developers="${developers}
${developer_entry}"
        else
            developers="${developer_entry}"
        fi
        committers_count=$((committers_count + 1))
    fi
done <<< "$sorted_contributors"

# Set thumbnail
if [ $top_contributor_count -eq 1 ]; then
    thumbnail_url="$top_contributor_avatar"
else
    thumbnail_url="https://i.imgur.com/qt1ixRk.gif"
    embed_color=$(hex_to_decimal "$default_color")
fi

# Truncate if too long
max_length=1000
commit_messages=$(echo "$COMMIT_LOGS" | sed 's/%0A/\n/g; s/^/\n/')
if [ ${#developers} -gt $max_length ]; then
    developers="${developers:0:$max_length}... (truncated)"
fi
if [ ${#commit_messages} -gt $max_length ]; then
    commit_messages="${commit_messages:0:$max_length}... (truncated)"
fi

# Determine ping
ping_variable=""
if [[ "$COMMIT_MESSAGE" == *"[Ping]"* ]] || [[ "$PING_DISCORD" == "true" ]]; then
    ping_variable="<@&1324799528255225997>"
fi

# Build Discord JSON payload
VERSION="$GITHUB_REF_NAME"
discord_data=$(jq -nc \
    --arg field_value "$commit_messages" \
    --arg author_value "$developers" \
    --arg footer_text "Version $VERSION" \
    --arg timestamp "$(date -u +%Y-%m-%dT%H:%M:%S.000Z)" \
    --arg thumbnail_url "$thumbnail_url" \
    --arg embed_color "$embed_color" \
    --arg ping "$ping_variable" \
    '{
        "content": $ping,
        "embeds": [
            {
                "title": "New Alpha-Build dropped 🔥",
                "color": ($embed_color | tonumber),
                "fields": [
                    {
                        "name": "Commits:",
                        "value": $field_value,
                        "inline": true
                    },
                    {
                        "name": "Developers:",
                        "value": $author_value,
                        "inline": false
                    }
                ],
                "footer": {
                    "text": $footer_text
                },
                "timestamp": $timestamp,
                "thumbnail": {
                    "url": $thumbnail_url
                }
            }
        ],
        "attachments": []
    }')

echo "Debug: Final Discord payload:"
echo "$discord_data"

# Send to Discord
curl -H "Content-Type: application/json" \
    -d "$discord_data" \
    "$DISCORD_WEBHOOK_URL"

# Send download links as separate message
APK_MESSAGE="[Download APK](https://drive.google.com/drive/folders/$GOOGLE_FOLDER_ANDROID)"
WINDOWS_MESSAGE="[Download Windows Installer](https://drive.google.com/drive/folders/$GOOGLE_FOLDER_MAIN)"
LINUX_MESSAGE="[Download Linux ZIP](https://drive.google.com/drive/folders/$GOOGLE_FOLDER_MAIN)"
IOS_MESSAGE="[Download iOS IPA](https://drive.google.com/drive/folders/$GOOGLE_FOLDER_MAIN)"
MACOS_MESSAGE="[Download macOS DMG](https://drive.google.com/drive/folders/$GOOGLE_FOLDER_MAIN)"

curl -H "Content-Type: application/json" \
    -d "{\"content\": \"${APK_MESSAGE}\n${WINDOWS_MESSAGE}\n${LINUX_MESSAGE}\n${IOS_MESSAGE}\n${MACOS_MESSAGE}\"}" \
    "$DISCORD_WEBHOOK_URL"

echo "Discord notification sent successfully!"