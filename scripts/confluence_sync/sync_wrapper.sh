#!/bin/bash
set -e

# Configuration
# 1. Load from confluence.conf if it exists
# 2. Otherwise use environment variables or defaults below
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
# Assuming script is in copilot-developer-skills/scripts/confluence_sync/
# and config is in copilot-developer-skills/config/
CONF_FILE="$SCRIPT_DIR/../../config/skill.conf"

if [ -f "$CONF_FILE" ]; then
    echo "Loading configuration from $CONF_FILE"
    source "$CONF_FILE"
fi

# Defaults (can still be overridden by env vars if not in conf file)
CONFLUENCE_URL="${CONFLUENCE_URL:-https://your-domain.atlassian.net/wiki}"
CONFLUENCE_USERNAME="${CONFLUENCE_USERNAME:-your-email@example.com}"
CONFLUENCE_TOKEN="${CONFLUENCE_TOKEN:-your-api-token}"
PAGE_ID="${PAGE_ID:-123456789}"
# Default output to copilot-developer-skills/docs/confluence relative to project root
# We assume the script is run from project root, and the script itself is in 
# copilot-developer-skills/scripts/confluence_sync/
OUTPUT_DIR="${OUTPUT_DIR:-copilot-developer-skills/docs/confluence}"
IS_CLOUD="${IS_CLOUD:-true}"

# CLI arguments
ARGS=()
ARGS+=(--url "$CONFLUENCE_URL")
ARGS+=(--username "$CONFLUENCE_USERNAME")
ARGS+=(--token "$CONFLUENCE_TOKEN")
ARGS+=(--page-id "$PAGE_ID")
ARGS+=(--out-dir "$OUTPUT_DIR")

if [ "$IS_CLOUD" = "true" ]; then
    ARGS+=(--cloud)
fi

# Run the script
echo "Syncing Confluence pages to $OUTPUT_DIR..."
python3 "$(dirname "$0")/confluence_to_md.py" "${ARGS[@]}"
echo "Done."
