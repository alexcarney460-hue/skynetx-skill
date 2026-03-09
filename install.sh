#!/bin/bash
# SkynetX Skill Installer for Claude Code
# Usage: curl -fsSL https://raw.githubusercontent.com/alexcarney460-hue/skynetx-skill/main/install.sh | bash

set -e

SKILL_DIR="$HOME/.claude/skills/skynetx"
REPO_URL="https://raw.githubusercontent.com/alexcarney460-hue/skynetx-skill/main"

echo "Installing SkynetX skill for Claude Code..."

mkdir -p "$SKILL_DIR"

curl -fsSL "$REPO_URL/SKILL.md" -o "$SKILL_DIR/SKILL.md"
curl -fsSL "$REPO_URL/api-reference.md" -o "$SKILL_DIR/api-reference.md"

echo ""
echo "SkynetX skill installed to $SKILL_DIR"
echo ""
echo "Next steps:"
echo "  1. Sign up at https://skynetx.io for your API key"
echo "  2. You get 100 free credits on signup"
echo "  3. Claude Code will now use SkynetX when building agents"
echo ""
echo "To verify: restart Claude Code and check that 'skynetx' appears in your skill list."
