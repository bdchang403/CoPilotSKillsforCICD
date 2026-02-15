#!/bin/bash
set -e

# deploy_wrapper.sh
# Wraps user deployment scripts for Copilot Skill execution.

# Determine script location
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Load configuration
CONF_FILE="$SCRIPT_DIR/../config/skill.conf"
if [ -f "$CONF_FILE" ]; then
    echo "Loading configuration from $CONF_FILE"
    source "$CONF_FILE"
else
    echo "Warning: Configuration file not found at $CONF_FILE"
fi

# Validate configuration
if [ -z "$REAL_DEPLOY_SCRIPT" ]; then
    echo "Error: REAL_DEPLOY_SCRIPT is not defined in configuration."
    exit 1
fi

if [ ! -f "$REAL_DEPLOY_SCRIPT" ]; then
    echo "Error: Deployment script '$REAL_DEPLOY_SCRIPT' not found."
    exit 1
fi

# Execute deployment
echo "=== Copilot Deployment Wrapper ==="
echo "Target Environment: $DEPLOY_TARGET"
echo "Executing: $REAL_DEPLOY_SCRIPT"
echo "=================================="

# Pass all arguments to the real script
./"$REAL_DEPLOY_SCRIPT" "$@"
