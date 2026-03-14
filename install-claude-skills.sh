#!/bin/bash
# ============================================================================
# install-claude-skills.sh
# Ktulue's Global Claude Code Skills Installer
# 
# Bootstraps all global Claude Code skills on any machine (Mac or WSL).
# Run once on a new device, or re-run to update/sync skills.
#
# Usage:
#   chmod +x install-claude-skills.sh
#   ./install-claude-skills.sh
#
# What it installs:
#   - Impeccable (frontend design quality — 1 skill + 17 commands)
#   - Sentry security-review & find-bugs (security methodology)
#   - OWASP Security (OWASP Top 10:2025, ASVS 5.0, language quirks)
#   - Custom Ktulue skills (uncomment when ready)
#
# What it checks for (requires manual install):
#   - SuperPowers (workflow — plugin, must install from inside Claude Code)
# ============================================================================

set -e

SKILLS_DIR="$HOME/.claude/skills"
COMMANDS_DIR="$HOME/.claude/commands"
TMP_DIR="/tmp/claude-skills-install"

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

info()  { echo -e "${GREEN}[✓]${NC} $1"; }
warn()  { echo -e "${YELLOW}[!]${NC} $1"; }
error() { echo -e "${RED}[✗]${NC} $1"; }

# --------------------------------------------------------------------------
# Pre-flight checks
# --------------------------------------------------------------------------
echo ""
echo "============================================"
echo "  Ktulue's Claude Code Skills Installer"
echo "============================================"
echo ""

# Check for required tools
command -v git >/dev/null 2>&1 || { error "git is required but not installed."; exit 1; }
command -v curl >/dev/null 2>&1 || { error "curl is required but not installed."; exit 1; }

# Check if Node/npx is available (needed for Impeccable)
HAS_NPX=false
if command -v npx >/dev/null 2>&1; then
    HAS_NPX=true
fi

# Create skills directory if it doesn't exist
mkdir -p "$SKILLS_DIR"
mkdir -p "$COMMANDS_DIR"

# Clean up any previous temp files
rm -rf "$TMP_DIR"
mkdir -p "$TMP_DIR"

# --------------------------------------------------------------------------
# 1. Impeccable — Frontend Design Quality
#    Source: https://github.com/pbakaus/impeccable
#    License: MIT
# --------------------------------------------------------------------------
echo ""
echo "--- Impeccable (Design Quality) ---"

if [ "$HAS_NPX" = true ]; then
    info "Installing Impeccable via npx skills (global)..."
    npx -y skills add pbakaus/impeccable -g -a claude-code -y 2>/dev/null && \
        info "Impeccable installed via npx skills." || {
            warn "npx skills failed — falling back to manual install..."
            git clone --depth 1 https://github.com/pbakaus/impeccable.git "$TMP_DIR/impeccable" 2>/dev/null
            if [ -d "$TMP_DIR/impeccable/dist/claude-code/.claude/skills" ]; then
                cp -r "$TMP_DIR/impeccable/dist/claude-code/.claude/skills/"* "$SKILLS_DIR/"
                info "Impeccable skills copied to $SKILLS_DIR"
            fi
            if [ -d "$TMP_DIR/impeccable/dist/claude-code/.claude/commands" ]; then
                cp -r "$TMP_DIR/impeccable/dist/claude-code/.claude/commands/"* "$COMMANDS_DIR/"
                info "Impeccable commands copied to $COMMANDS_DIR"
            fi
        }
else
    warn "npx not found — installing Impeccable manually..."
    git clone --depth 1 https://github.com/pbakaus/impeccable.git "$TMP_DIR/impeccable" 2>/dev/null
    if [ -d "$TMP_DIR/impeccable/dist/claude-code/.claude/skills" ]; then
        cp -r "$TMP_DIR/impeccable/dist/claude-code/.claude/skills/"* "$SKILLS_DIR/"
        info "Impeccable skills copied to $SKILLS_DIR"
    fi
    if [ -d "$TMP_DIR/impeccable/dist/claude-code/.claude/commands" ]; then
        cp -r "$TMP_DIR/impeccable/dist/claude-code/.claude/commands/"* "$COMMANDS_DIR/"
        info "Impeccable commands copied to $COMMANDS_DIR"
    fi
fi

# --------------------------------------------------------------------------
# 2. Sentry Skills — Security Review & Bug Finding
#    Source: https://github.com/getsentry/skills
#    License: Apache-2.0
# --------------------------------------------------------------------------
echo ""
echo "--- Sentry Skills (Security) ---"

git clone --depth 1 https://github.com/getsentry/skills.git "$TMP_DIR/sentry-skills" 2>/dev/null

SENTRY_SKILLS_SRC="$TMP_DIR/sentry-skills/plugins/sentry-skills/skills"

# Install specific security-focused skills (not the full Sentry suite)
SENTRY_TARGETS=("find-bugs" "security-review" "code-review" "gha-security-review")

for skill in "${SENTRY_TARGETS[@]}"; do
    if [ -d "$SENTRY_SKILLS_SRC/$skill" ]; then
        cp -r "$SENTRY_SKILLS_SRC/$skill" "$SKILLS_DIR/"
        info "Installed sentry/$skill"
    else
        warn "Sentry skill '$skill' not found — may have been renamed or moved."
    fi
done

# --------------------------------------------------------------------------
# 3. OWASP Security — Standards & Best Practices Reference
#    Source: https://github.com/agamm/claude-code-owasp
#    License: Open source
# --------------------------------------------------------------------------
echo ""
echo "--- OWASP Security (Standards) ---"

mkdir -p "$SKILLS_DIR/owasp-security"
curl -sL \
    "https://raw.githubusercontent.com/agamm/claude-code-owasp/main/.claude/skills/owasp-security/SKILL.md" \
    -o "$SKILLS_DIR/owasp-security/SKILL.md"

# Also grab the reference doc if it exists
curl -sL \
    "https://raw.githubusercontent.com/agamm/claude-code-owasp/main/.claude/skills/owasp-security/OWASP-2025-2026-Report.md" \
    -o "$SKILLS_DIR/owasp-security/OWASP-2025-2026-Report.md" 2>/dev/null || true

if [ -f "$SKILLS_DIR/owasp-security/SKILL.md" ]; then
    info "Installed owasp-security"
else
    error "Failed to download OWASP skill."
fi

# --------------------------------------------------------------------------
# 4. Custom Ktulue Skills
#    Source: https://github.com/Ktulue/claude-skills (private)
#
#    Uncomment the block below once you have custom skills in a repo.
#    This assumes the repo has skills as top-level directories, e.g.:
#      claude-skills/
#        pr-summary-generator/SKILL.md
#        narrator/SKILL.md
#        depthcheck/SKILL.md
# --------------------------------------------------------------------------
echo ""
echo "--- Custom Ktulue Skills ---"

# UNCOMMENT WHEN READY:
# if git clone --depth 1 https://github.com/Ktulue/claude-skills.git "$TMP_DIR/ktulue-skills" 2>/dev/null; then
#     for skill_dir in "$TMP_DIR/ktulue-skills"/*/; do
#         if [ -f "$skill_dir/SKILL.md" ]; then
#             skill_name=$(basename "$skill_dir")
#             cp -r "$skill_dir" "$SKILLS_DIR/"
#             info "Installed ktulue/$skill_name"
#         fi
#     done
# else
#     warn "Could not clone Ktulue skills repo (private repo — ensure SSH key is set up)."
# fi

warn "Custom Ktulue skills section is commented out — uncomment when repo is ready."

# --------------------------------------------------------------------------
# Cleanup
# --------------------------------------------------------------------------
echo ""
echo "--- Cleanup ---"
rm -rf "$TMP_DIR"
info "Temp files cleaned up."

# --------------------------------------------------------------------------
# 5. SuperPowers Check (Plugin — requires manual install inside Claude Code)
#    Source: https://github.com/obra/superpowers
#    License: MIT
#
#    SuperPowers is a plugin with hooks, agents, and a session-start
#    bootstrap. It cannot be installed via file copy — it must be installed
#    through Claude Code's plugin marketplace from inside a session.
# --------------------------------------------------------------------------
echo ""
echo "--- SuperPowers (Workflow) ---"

SUPERPOWERS_INSTALLED=false
PLUGINS_CACHE="$HOME/.claude/plugins/cache"

# Check common locations where SuperPowers installs itself
if [ -d "$PLUGINS_CACHE/Superpowers" ] || \
   [ -d "$PLUGINS_CACHE/superpowers" ] || \
   ls "$HOME/.claude/plugins/"*superpowers* 1>/dev/null 2>&1; then
    SUPERPOWERS_INSTALLED=true
    info "SuperPowers is already installed."
else
    warn "SuperPowers is NOT installed."
    echo ""
    echo "  SuperPowers is a plugin and must be installed from inside Claude Code."
    echo "  Open Claude Code and run these two commands:"
    echo ""
    echo "    /plugin marketplace add obra/superpowers-marketplace"
    echo "    /plugin install superpowers@superpowers-marketplace"
    echo ""
    echo "  Then restart Claude Code."
    echo ""
fi

# --------------------------------------------------------------------------
# Summary
# --------------------------------------------------------------------------
echo ""
echo "============================================"
echo "  Installation Complete"
echo "============================================"
echo ""
echo "  Installed to: $SKILLS_DIR"
echo ""
echo "  Skills installed:"
ls -1 "$SKILLS_DIR" 2>/dev/null | while read -r dir; do
    if [ -f "$SKILLS_DIR/$dir/SKILL.md" ]; then
        echo "    - $dir"
    fi
done
echo ""
echo "  Commands installed:"
ls -1 "$COMMANDS_DIR" 2>/dev/null | while read -r file; do
    echo "    - $file"
done
echo ""
if [ "$SUPERPOWERS_INSTALLED" = true ]; then
    echo "  SuperPowers: Installed"
else
    echo "  SuperPowers: NOT INSTALLED — see instructions above"
fi
echo ""
echo "  Restart Claude Code to pick up new skills."
echo ""