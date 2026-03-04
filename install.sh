#!/bin/bash

# Presentation Tools - Installer Script
# For Spotify Creative Teams
#
# Usage: curl -fsSL https://gist.githubusercontent.com/rlester7/89dd039a98121333dae739064c3f7225/raw/install.sh | bash

# Don't exit on error - we'll handle errors ourselves
set +e

# -----------------------------------------------------------------------------
# Configuration
# -----------------------------------------------------------------------------

# Gist URL for skill distribution (repo is private, gist is public)
GIST_RAW="https://gist.githubusercontent.com/rlester7/89dd039a98121333dae739064c3f7225/raw"

# Skills to install (skill_name:has_subdirs)
# has_subdirs: 0 = just SKILL.md, 1 = has subdirectories to download
declare -a SKILLS=(
    "create-presentation-site:1"
    "frontend-design:0"
    "create-moodboard:1"
    "marketing-experience:1"
)

# -----------------------------------------------------------------------------
# Helper Functions
# -----------------------------------------------------------------------------

retry() {
    local max_attempts=$1
    local delay=$2
    shift 2
    local attempt=1

    while [ $attempt -le $max_attempts ]; do
        if "$@"; then
            return 0
        fi
        echo "  Attempt $attempt failed. Retrying in ${delay}s..."
        sleep $delay
        attempt=$((attempt + 1))
    done

    echo "  ❌ Failed after $max_attempts attempts"
    return 1
}

check_internet() {
    curl -fsSL --connect-timeout 5 https://google.com > /dev/null 2>&1
}

download_file() {
    local url=$1
    local dest=$2
    curl -fsSL "$url" -o "$dest" 2>/dev/null
}

# -----------------------------------------------------------------------------
# Pre-flight Checks
# -----------------------------------------------------------------------------

echo ""
echo "🎨 Presentation Tools - Setup"
echo "============================="
echo ""

# Check macOS
if [[ "$(uname)" != "Darwin" ]]; then
    echo "❌ This installer is for macOS only."
    exit 1
fi

# Check internet
echo "Checking internet connection..."
if ! check_internet; then
    echo "  ❌ No internet connection. Please connect and try again."
    exit 1
fi
echo "  ✅ Connected"

# -----------------------------------------------------------------------------
# Step 1: Group Membership Reminder
# -----------------------------------------------------------------------------

echo ""
echo "[Step 1/4] Group Membership Check"
echo ""
echo "   ⚠️  You must be a member of the Claude Code Users group"
echo ""
echo "   If you haven't already, join here:"
echo "   https://backstage.spotify.net/bandmanager/okta-c4e-chat-and-code-users@spotify.com"
echo ""
echo "   Note: It can take up to 4-6 hours for group access to sync."
echo "   If you just joined, you may need to log out of Okta and back in."
echo ""

# Try to prompt for confirmation, but don't fail if TTY is unavailable
if [ -t 0 ] || [ -e /dev/tty ]; then
    echo -n "   Press Enter to continue..."
    read </dev/tty 2>/dev/null || {
        echo ""
        echo "   (Continuing automatically - make sure you've joined the group!)"
        sleep 3
    }
else
    echo "   (Continuing automatically - make sure you've joined the group!)"
    sleep 3
fi

# -----------------------------------------------------------------------------
# Step 2: Install Claude Code
# -----------------------------------------------------------------------------

echo ""
echo "📦 [Step 2/4] Installing Claude Code..."

if ! command -v claude &> /dev/null; then
    if retry 2 5 bash -c "curl -fsSL https://claude.ai/install.sh | bash" </dev/tty 2>&1; then
        # Add to PATH for this session
        export PATH="$HOME/.local/bin:$PATH"
        echo "  ✅ Claude Code installed"
    else
        echo "  ⚠️  Failed to install Claude Code"
        echo "     You can install it later: curl -fsSL https://claude.ai/install.sh | bash"
        echo "     Continuing with setup..."
    fi
else
    echo "  ✅ Claude Code already installed"
fi

# -----------------------------------------------------------------------------
# Step 3: Install Skills
# -----------------------------------------------------------------------------

echo ""
echo "🎨 [Step 3/4] Installing presentation skills..."

for skill_entry in "${SKILLS[@]}"; do
    skill_name="${skill_entry%%:*}"
    has_subdirs="${skill_entry##*:}"

    echo "  Installing $skill_name..."

    # Create skill directory
    mkdir -p ~/.claude/skills/$skill_name

    # Download main SKILL.md (gist uses flat naming: skillname.SKILL.md)
    if ! download_file "${GIST_RAW}/${skill_name}.SKILL.md" ~/.claude/skills/$skill_name/SKILL.md; then
        echo "    ❌ Failed to download $skill_name skill"
        continue
    fi

    # Download subdirectories if needed
    if [[ "$has_subdirs" == "1" ]]; then
        case "$skill_name" in
            "create-presentation-site")
                # Create subdirectories
                mkdir -p ~/.claude/skills/$skill_name/{templates,fonts}

                # Download templates (gist flat naming: skillname.templatename)
                for template in "style-preview.html" "section-hero.html" "section-feature-cards.html" "section-image-showcase.html" "section-comparison-table.html" "section-stats.html" "section-quote.html" "section-timeline.html" "section-cta.html"; do
                    download_file "${GIST_RAW}/${skill_name}.${template}" \
                        ~/.claude/skills/$skill_name/templates/$template
                done

                # Download fonts (gist flat naming: skillname.fontname)
                for font in "SpotifyMix-Regular.otf" "SpotifyMix-Medium.otf" "SpotifyMix-Bold.otf" "SpotifyMix-Extrabold.otf"; do
                    download_file "${GIST_RAW}/${skill_name}.${font}" \
                        ~/.claude/skills/$skill_name/fonts/$font
                done
                ;;
            "create-moodboard")
                # Create subdirectories
                mkdir -p ~/.claude/skills/$skill_name/{assets,references,scripts}

                # Download assets (gist flat naming: skillname.filename)
                download_file "${GIST_RAW}/${skill_name}.moodboard-template.html" \
                    ~/.claude/skills/$skill_name/assets/moodboard-template.html

                # Download references
                download_file "${GIST_RAW}/${skill_name}.layout-patterns.md" \
                    ~/.claude/skills/$skill_name/references/layout-patterns.md

                # Download scripts
                download_file "${GIST_RAW}/${skill_name}.crop_image.py" \
                    ~/.claude/skills/$skill_name/scripts/crop_image.py
                download_file "${GIST_RAW}/${skill_name}.extract_colors.py" \
                    ~/.claude/skills/$skill_name/scripts/extract_colors.py

                # Make scripts executable
                chmod +x ~/.claude/skills/$skill_name/scripts/*.py 2>/dev/null
                ;;
            "marketing-experience")
                # Create fonts directory
                mkdir -p ~/.claude/skills/$skill_name/fonts

                # Download fonts (gist flat naming: skillname.fontname)
                for font in "SpotifyMix-Regular.otf" "SpotifyMix-Medium.otf" "SpotifyMix-Bold.otf" "SpotifyMix-Extrabold.otf"; do
                    download_file "${GIST_RAW}/${skill_name}.${font}" \
                        ~/.claude/skills/$skill_name/fonts/$font
                done
                ;;
        esac
    fi

    echo "    ✅ $skill_name installed"
done

# -----------------------------------------------------------------------------
# Step 4: Verification
# -----------------------------------------------------------------------------

echo ""
echo "🔍 [Step 4/4] Verifying installation..."

ERRORS=0
WARNINGS=0

# Check claude command
if command -v claude &> /dev/null; then
    echo "  ✅ Claude Code command available"
else
    # Check if it exists but not in PATH
    if [ -f "$HOME/.local/bin/claude" ]; then
        echo "  ⚠️  Claude Code installed but not in PATH"
        echo "     Run: echo 'export PATH=\"\$HOME/.local/bin:\$PATH\"' >> ~/.zshrc && source ~/.zshrc"
        WARNINGS=$((WARNINGS + 1))
    else
        echo "  ❌ Claude Code not found"
        ERRORS=$((ERRORS + 1))
    fi
fi

# Check all skills
for skill_entry in "${SKILLS[@]}"; do
    skill_name="${skill_entry%%:*}"

    # Check for either SKILL.md or skill.md
    if [ -f ~/.claude/skills/$skill_name/SKILL.md ] || [ -f ~/.claude/skills/$skill_name/skill.md ]; then
        echo "  ✅ $skill_name skill installed"
    else
        echo "  ❌ $skill_name skill not found"
        ERRORS=$((ERRORS + 1))
    fi
done

# Check for Pillow (optional, for moodboard scripts)
if python3 -c "import PIL" 2>/dev/null; then
    echo "  ✅ Pillow available (for moodboard image tools)"
else
    echo "  ℹ️  Pillow not installed (optional, for moodboard image tools)"
    echo "     Install with: pip install Pillow"
fi

# -----------------------------------------------------------------------------
# Done: Success Message
# -----------------------------------------------------------------------------

echo ""
if [ $ERRORS -eq 0 ] && [ $WARNINGS -eq 0 ]; then
    echo "🎉 Setup complete!"
    echo ""
    echo "Installed skills:"
    echo "  • create-presentation-site - Build polished presentation websites"
    echo "  • frontend-design - Create distinctive, high-quality interfaces"
    echo "  • create-moodboard - Create visual moodboards from reference images"
    echo "  • marketing-experience - Build Spotify Marketing Experience prototypes"
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "  🔐 NEXT: Log in with SSO"
    echo ""
    echo "  1. Open a NEW Terminal window"
    echo "  2. Run: claude"
    echo "  3. When prompted, select: Login"
    echo "  4. Select: Claude account with subscription"
    echo "  5. A browser will open — sign in with your @spotify.com email"
    echo "  6. Select 'Spotify' org if prompted"
    echo ""
    echo "  Tip: Disable adblockers (uBlock etc.) before signing in at claude.ai"
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "  To verify: type /status in Claude Code"
    echo "  You should see: Organization: Spotify"
    echo ""
    echo "Have fun! 🎵"
elif [ $ERRORS -eq 0 ]; then
    echo "✅ Setup complete with $WARNINGS minor warning(s)"
    echo ""
    echo "Next steps:"
    echo ""
    echo "  1. Open a NEW Terminal window (important!)"
    echo "  2. Run: claude"
    echo "  3. Log in with SSO when prompted (use your @spotify.com email)"
    echo "  4. Verify with /status — should show Organization: Spotify"
    echo ""
else
    echo "⚠️  Setup completed with $ERRORS error(s) and $WARNINGS warning(s)"
    echo ""
    echo "   Some components may not work correctly."
    echo "   Try opening a new Terminal and running the installer again."
    echo "   If issues persist, ask for help."
fi

echo ""
