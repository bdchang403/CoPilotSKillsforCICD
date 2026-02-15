#!/bin/bash

# setup.sh - Installer for Copilot Deployment Skill

set -e

# Detect the directory where this script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
TEMPLATE_DIR="$SCRIPT_DIR"

if [ ! -d "$TEMPLATE_DIR" ]; then
    echo "Error: Template directory not found at $TEMPLATE_DIR"
    exit 1
fi

echo "=== GitHub Copilot Skill Installer ==="
echo "This script will set up the Deployment Skill in your current repository."
echo ""

# 1. Prompt for Configuration
read -p "Enter the name of your self-hosted runner scale set [my-runner-set]: " RUNNER_SET
RUNNER_SET=${RUNNER_SET:-my-runner-set}

read -p "Enter the deployment target URL/Environment [production]: " DEPLOY_ENV
DEPLOY_ENV=${DEPLOY_ENV:-production}

read -p "Enter the Legacy Pipeline Gateway/Connectivity [vmc2-gateway.internal]: " CONNECTIVITY
CONNECTIVITY=${CONNECTIVITY:-vmc2-gateway.internal}

read -p "Enter the path to your deployment script (relative to repo root) [scripts/deploy.sh]: " DEPLOY_SCRIPT
DEPLOY_SCRIPT=${DEPLOY_SCRIPT:-scripts/deploy.sh}

echo ""
echo "Configuration:"
echo "  Runner Set: $RUNNER_SET"
echo "  Deploy Env: $DEPLOY_ENV"
echo "  Connectivity: $CONNECTIVITY"
echo "  Script:     $DEPLOY_SCRIPT"
echo ""
read -p "Proceed with installation? (y/N) " CONFIRM
if [[ ! "$CONFIRM" =~ ^[Yy]$ ]]; then
    echo "Installation aborted."
    exit 0
fi

# 2. Copy Skill Files
echo "Copying skill files..."
mkdir -p .github/skills/deploy-skill
cp "$TEMPLATE_DIR/.github/skills/deploy-skill/SKILL.md" .github/skills/deploy-skill/

# Define containment directory
SKILL_ROOT="copilot-developer-skills"
mkdir -p "$SKILL_ROOT/scripts"
mkdir -p "$SKILL_ROOT/config"
mkdir -p "$SKILL_ROOT/docs"

echo "Installing assets to $SKILL_ROOT/..."

cp "$TEMPLATE_DIR/scripts/deploy_wrapper.sh" "$SKILL_ROOT/scripts/"

if [ ! -f "$SKILL_ROOT/config/skill.conf" ]; then
    cp "$TEMPLATE_DIR/config/skill.conf.example" "$SKILL_ROOT/config/skill.conf"
else
    echo "  $SKILL_ROOT/config/skill.conf already exists, skipping copy."
fi

# Copy Confluence Sync Scripts
if [ -d "$TEMPLATE_DIR/scripts/confluence_sync" ]; then
    echo "Copying Confluence sync scripts..."
    cp -r "$TEMPLATE_DIR/scripts/confluence_sync" "$SKILL_ROOT/scripts/"
fi

# Copy Documentation
if [ -d "$TEMPLATE_DIR/docs" ]; then
    echo "Copying documentation..."
    cp -r "$TEMPLATE_DIR/docs/"* "$SKILL_ROOT/docs/"
fi

# 3. Generate Configuration
echo "Generating configuration..."
# specific replacement in SKILL.md
# Note: In a real scenario, we might want to keep the placeholders and let the wrapper handle it,
# but replacing in SKILL.md makes the instructions clearer to the Agent.
sed -i "s|{{RUNNER_SET}}|$RUNNER_SET|g" .github/skills/deploy-skill/SKILL.md
sed -i "s|{{DEPLOY_ENV}}|$DEPLOY_ENV|g" .github/skills/deploy-skill/SKILL.md
sed -i "s|{{CONNECTIVITY}}|$CONNECTIVITY|g" .github/skills/deploy-skill/SKILL.md

# generating local config file for the wrapper script
cat > "$SKILL_ROOT/config/skill.conf" <<EOL
# Local Configuration for Deployment Skill
# This file is ignored by git.

RUNNER_SET="$RUNNER_SET"
DEPLOY_TARGET="$DEPLOY_ENV"
REAL_DEPLOY_SCRIPT="$DEPLOY_SCRIPT"
EOL

# 4. Update .gitignore
if ! grep -q "$SKILL_ROOT/config/skill.conf" .gitignore 2>/dev/null; then
    echo "Adding $SKILL_ROOT/config/skill.conf to .gitignore..."
    echo "$SKILL_ROOT/config/skill.conf" >> .gitignore
fi

echo ""
echo "=== Installation Complete ==="
echo "Next Steps:"
echo "1. Verify .github/skills/deploy-skill/SKILL.md"
echo "2. Ensure '$DEPLOY_SCRIPT' exists and is executable."
echo "3. Commit the changes (excluding $SKILL_ROOT/config/skill.conf)."
