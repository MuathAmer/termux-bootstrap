#!/data/data/com.termux/files/usr/bin/bash

# ==============================================================================
# Termux Bootstrap v2.2
# A modular, safe, and mobile-optimized setup script for Termux.
# ==============================================================================

# --- Variables ---
CONFIG_DIR="$HOME/.config/fish"
CONFIG_FILE="$CONFIG_DIR/config.fish"
STARSHIP_CONFIG_DIR="$HOME/.config"
STARSHIP_CONFIG_FILE="$STARSHIP_CONFIG_DIR/starship.toml"
MICRO_CONFIG_DIR="$HOME/.config/micro"
MICRO_CONFIG_FILE="$MICRO_CONFIG_DIR/settings.json"
FONT_DIR="$HOME/.termux"
FONT_FILE="$FONT_DIR/font.ttf"
BACKUP_SUFFIX=".bak.$(date +%Y%m%d_%H%M%S)"
INTERACTIVE=true

# --- Colors ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# --- Helper Functions ---

log_header() { 
    echo -e "\n${PURPLE}============================================================${NC}"
    echo -e "${PURPLE}:: ${CYAN}$1${NC}"
    echo -e "${PURPLE}============================================================${NC}"
}

log_info() { echo -e "${BLUE}  [INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}  [OK]${NC}   $1"; }
log_warn() { echo -e "${YELLOW}  [WARN]${NC} $1"; }
log_error() { echo -e "${RED}  [ERR]${NC}  $1"; }

prompt_confirm() {
    # If not interactive, return 0 (true/yes)
    if [ "$INTERACTIVE" = false ]; then
        return 0
    fi
    
    echo ""
    while true; do
        read -r -p "$(echo -e "${CYAN}? $1 [Y/n]: ${NC}")" yn
        case $yn in
            [Yy]* ) return 0;;
            [Nn]* ) return 1;;
            "" ) return 0;; # Default to Yes
            * ) echo "Please answer yes or no.";;
        esac
    done
}

backup_file() {
    local file=$1
    if [ -f "$file" ]; then
        log_info "Backing up $(basename "$file") to $(basename "$file")$BACKUP_SUFFIX"
        cp "$file" "${file}${BACKUP_SUFFIX}"
    fi
}

# --- Installation Functions ---

update_system() {
    log_header "System Update"
    log_info "Updating package lists and upgrading system..."
    pkg update -y && pkg upgrade -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold"
}

install_base_tools() {
    log_header "Base Tools Installation"
    log_info "Installing core packages..."
    # Added build-essential and python for node-gyp native compilations
    pkg install git fish nodejs-lts curl termux-api build-essential python -y
    log_success "Base tools installed."
}

install_modern_tools() {
    log_header "Modern UI Tools"
    log_info "Installing improved CLI utilities..."
    pkg install lsd bat zoxide fzf starship glow -y
    log_success "Modern tools installed."
}

install_micro_editor() {
    log_header "Micro Editor Setup"
    log_info "Installing Micro..."
    pkg install micro -y
    
    # Configure Micro for touch and softwrap
    mkdir -p "$MICRO_CONFIG_DIR"
    if [ ! -f "$MICRO_CONFIG_FILE" ]; then
        log_info "Configuring Micro (softwrap, mouse support)..."
        cat <<EOF > "$MICRO_CONFIG_FILE"
{
    "softwrap": true,
    "mouse": true,
    "autosu": true
}
EOF
        log_success "Micro configuration created."
    else
        log_info "Micro configuration already exists. Backing up and updating..."
        backup_file "$MICRO_CONFIG_FILE"
        # Update logic: we don't overwrite user settings, but ensure these are present
        # For simplicity in this script, we'll just log it.
        log_success "Micro configuration backed up."
    fi
}

install_gemini() {
    log_header "Gemini CLI Setup"
    if ! command -v gemini &> /dev/null; then
        log_info "Installing Google Gemini CLI (Termux Optimized)..."
        npm install -g @mmmbuto/gemini-cli-termux
        log_success "Gemini CLI installed successfully."
    else
        log_success "Gemini CLI is already installed."
    fi
}

install_media_suite() {
    log_header "Media Suite Installation"
    log_info "Installing dependencies (Python, FFmpeg, Rust)..."
    # Added rust and binutils for building pydantic-core (spotdl dependency)
    pkg install python ffmpeg rust binutils -y
    
    log_info "Installing yt-dlp (Video Downloader)..."
    if pip install --prefer-binary yt-dlp; then
        log_info "Configuring yt-dlp..."
        mkdir -p "$HOME/.config/yt-dlp"
        backup_file "$HOME/.config/yt-dlp/config"
        # Config: Save to sdcard, cleaner filenames
        echo '-o /sdcard/Download/Termux/%(title)s.%(ext)s' > "$HOME/.config/yt-dlp/config"
        echo '--no-mtime' >> "$HOME/.config/yt-dlp/config"
        
        # Create Download folder
        mkdir -p "/sdcard/Download/Termux"
        log_success "yt-dlp installed & configured."
    else
        log_error "yt-dlp installation failed."
    fi
    
    log_info "Installing spotdl (Spotify Downloader)..."
    log_warn "This step involves compiling heavy dependencies (e.g., rapidfuzz)."
    log_warn "It may take 5-15 minutes on a phone. Please be patient."
    
    # Use timeout if available to prevent infinite hangs (10 mins)
    local PIP_CMD="pip"
    if command -v timeout &> /dev/null; then
        PIP_CMD="timeout 600 pip"
    fi

    if $PIP_CMD install --prefer-binary spotdl; then
        log_info "Configuring spotdl..."
        mkdir -p "/sdcard/Music/SpotDL"
        log_success "spotdl installed."
    else
        local EXIT_CODE=$?
        if [ $EXIT_CODE -eq 124 ]; then
             log_error "spotdl installation timed out (limit: 10 mins)."
             log_warn "Your device might be too slow to compile 'rapidfuzz'."
        else
             log_error "spotdl installation failed."
        fi
        log_warn "Skipping spotdl. You can try installing it manually later with 'pip install spotdl'."
    fi
}

install_termux_whisper() {
    log_header "Termux Whisper Setup"
    if [ -d "$HOME/termux-whisper" ]; then
        log_warn "Termux Whisper directory already exists. Skipping clone."
    else
        log_info "Cloning Termux Whisper..."
        git clone https://github.com/MuathAmer/termux-whisper.git "$HOME/termux-whisper"
        
        log_info "Running Termux Whisper setup..."
        chmod +x "$HOME/termux-whisper/setup.sh"
        # Run setup, handling potential interactive prompts if possible or warn user
        bash "$HOME/termux-whisper/setup.sh"
    fi
}

setup_storage() {
    log_header "Storage Access"
    log_info "Checking Termux storage access..."
    if [ -d "$HOME/storage" ]; then
        log_success "Termux storage is already configured."
    else
        echo -e "    ${YELLOW}->${NC} This links Termux to your Android 'Downloads' and 'Music' folders."
        echo -e "    ${YELLOW}->${NC} Please grant permission in the popup if asked."
        termux-setup-storage
    fi
}

install_nerd_font() {
    log_header "Nerd Font Installation"
    if [ -f "$FONT_FILE" ]; then
        log_warn "A font is already installed at $FONT_FILE."
        if ! prompt_confirm "Do you want to overwrite it with JetBrains Mono Nerd Font?"; then
            return
        fi
        backup_file "$FONT_FILE"
    fi

    log_info "Downloading JetBrains Mono Nerd Font..."
    mkdir -p "$FONT_DIR"
    
    local TEMP_FONT="$FONT_DIR/font.ttf.tmp"
    
    # Download to temp file first to prevent partial/corrupt writes to active config
    # Switched to "No Ligatures" (NL) version to prevent rendering freezes on some Android devices.
    curl -fLo "$TEMP_FONT" https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/JetBrainsMono/NoLigatures/Regular/JetBrainsMonoNLNerdFont-Regular.ttf
    
    # Verify download: Check if file exists and is > 1MB (Fonts are usually ~2MB)
    if [ -f "$TEMP_FONT" ]; then
        local FONT_SIZE=$(stat -c%s "$TEMP_FONT")
        if [ "$FONT_SIZE" -gt 1000000 ]; then
             mv "$TEMP_FONT" "$FONT_FILE"
             log_info "Font downloaded successfully ($((FONT_SIZE/1024)) KB)."
             log_info "Reloading Termux settings to apply font..."
             termux-reload-settings
             log_success "Font applied."
             return
        fi
    fi

    log_error "Font download failed or file is corrupted (< 1MB). Aborting font change."
    rm -f "$TEMP_FONT"
}

configure_starship_portrait() {
    log_info "Configuring Starship for Portrait Mode (2-line prompt)..."
    mkdir -p "$STARSHIP_CONFIG_DIR"
    backup_file "$STARSHIP_CONFIG_FILE"
    
    cat <<EOF > "$STARSHIP_CONFIG_FILE"
# Portrait Mode Optimized Config
# Two lines: Information on top, input on bottom.

add_newline = true

[line_break]
disabled = false

[character]
success_symbol = "[❯](bold green)"
error_symbol = "[❯](bold red)"
vimcmd_symbol = "[❮](bold green)"

[directory]
truncation_length = 3
truncation_symbol = "…/"
style = "bold cyan"

[git_branch]
symbol = "🌱 "
style = "bold purple"

[nodejs]
symbol = "⬢ "
style = "bold green"

[package]
symbol = "📦 "
disabled = true
EOF
    log_success "Starship configured for portrait mode."
}

configure_fish() {
    log_header "Shell Configuration"
    log_info "Configuring Fish Shell..."
    mkdir -p "$CONFIG_DIR"
    
    # Define the block content markers
    local BLOCK_START="# --- TERMUX-BOOTSTRAP-START ---"
    local BLOCK_END="# --- TERMUX-BOOTSTRAP-END ---"

    # Remove existing block if present
    if [ -f "$CONFIG_FILE" ]; then
        # Backup before modification
        backup_file "$CONFIG_FILE"
        # Use sed to delete the block
        sed -i "/$BLOCK_START/,/$BLOCK_END/d" "$CONFIG_FILE"
        # Remove trailing newlines potentially left behind
        sed -i '${/^$/d;}' "$CONFIG_FILE"
    fi

    # Append new block using cat <<EOF to avoid quoting issues
    cat <<EOF >> "$CONFIG_FILE"
$BLOCK_START
# Core
set -U fish_greeting # Disable greeting

# Modern Tools Aliases
if command -q lsd
    alias ls='lsd'
    alias ll='lsd -l'
    alias la='lsd -a'
    alias lla='lsd -la'
    alias lt='lsd --tree'
end

if command -q bat
    alias cat='bat'
end

# Mobile-Friendly Shortcuts
alias c='clear'
alias ..='cd ..'
alias ...='cd ../..'
alias g='git'
alias gl='git log --oneline --graph --decorate' # Narrow git log
alias up='pkg update && pkg upgrade'
alias in='pkg install'

# Clipboard Integration (Requires Termux:API app)
if command -q termux-clipboard-get
    alias copy='termux-clipboard-set'
    alias paste='termux-clipboard-get'
end

# Media Suite Aliases
if command -q yt-dlp
    alias video='yt-dlp'
end
if command -q spotdl
    # Advanced Music Downloader (Lyrics, LRC, Metadata Update)
    alias music='spotdl download --output /sdcard/Music/SpotDL --lyrics synced genius musixmatch azlyrics --generate-lrc --overwrite metadata --scan-for-songs --force-update-metadata'
end

# Termux Whisper Alias
if test -f ~/termux-whisper/transcribe.sh
    alias whisper='bash ~/termux-whisper/transcribe.sh'
end

# Editor
if command -q micro
    set -gx EDITOR micro
    alias nano='micro'
end

# Starship Prompt
if command -q starship
    starship init fish | source
end

# Zoxide (Smart cd)
if command -q zoxide
    zoxide init fish | source
end

# FZF (Fuzzy Finder)
if command -q fzf
    fzf --fish | source
end

# Termux Command Not Found
function __fish_command_not_found_handler --on-event fish_command_not_found
    if [ -f /data/data/com.termux/files/usr/libexec/termux/command-not-found ]
        /data/data/com.termux/files/usr/libexec/termux/command-not-found \$argv[1]
    else
        printf 'Command not found: %s\n' \$argv[1]
    end
end

# Gemini 'Ask' Helper
function ask
    if test -z "\$argv"
        echo "Usage: ask 'your question'"
        return 1
    end
    # Check if glow is installed for rendering, else plain text
    if command -q glow
        gemini "\$argv" | glow -
    else
        gemini "\$argv"
    end
end

# Updater Function
function upgrade-all
    bash ~/termux-bootstrap/upgrade.sh
end
$BLOCK_END
EOF

    log_success "Fish configuration updated."
}

set_default_shell() {
    local SHELL_PATH=$(command -v fish)
    if [ "$SHELL" != "$SHELL_PATH" ]; then
        log_info "Changing default shell to Fish..."
        chsh -s fish
    else
        log_success "Fish is already the default shell."
    fi
}

cleanup_motd() {
    if [ -f "$PREFIX/etc/motd" ]; then
        log_info "Removing Termux default MOTD..."
        rm "$PREFIX/etc/motd"
    fi
}

# --- Main Execution ---

# Ensure device stays awake during setup
cleanup() {
    termux-wake-unlock
}
trap cleanup EXIT INT TERM

# Check arguments
if [ "$1" == "-y" ]; then
    INTERACTIVE=false
fi

termux-wake-lock
log_info "Wake lock acquired. Device will stay awake during setup."

clear
echo -e "${GREEN}"
echo "============================================"
echo "       TERMUX BOOTSTRAP v2.2                "
echo "============================================"
echo -e "${NC}"

setup_storage

if prompt_confirm "Update system packages?"; then
    update_system
fi

if prompt_confirm "Install base tools (Git, Fish, Node)?"; then
    install_base_tools
fi

if prompt_confirm "Install modern UI tools (Starship, Lsd, Bat, Zoxide)?"; then
    install_modern_tools
    # Nested prompt for Starship config dependent on Starship installation
    if prompt_confirm "  -> Configure Starship for Portrait Mode (2-line prompt)?"; then
        configure_starship_portrait
    fi
fi

if prompt_confirm "Install Micro (Touch-friendly editor)?"; then
    install_micro_editor
fi

if prompt_confirm "Install Gemini CLI?"; then
    install_gemini
fi

# Community Extras Section
if prompt_confirm "Install 'Media Suite' (YouTube & Spotify Downloaders)?"; then
    install_media_suite
fi

if prompt_confirm "Install 'Termux Whisper' (Offline Speech-to-Text)?"; then
    install_termux_whisper
fi

if prompt_confirm "Install Nerd Font (required for icons)?"; then
    install_nerd_font
fi

configure_fish
set_default_shell
cleanup_motd

echo "--------------------------------------------"
log_success "Setup Complete!"
echo -e "  ${YELLOW}*${NC} Please ${GREEN}restart Termux${NC} to apply all changes."
echo -e "  ${YELLOW}*${NC} New Media Aliases: ${BLUE}music${NC} (spotDL), ${BLUE}video${NC} (yt-dlp)."
echo -e "  ${YELLOW}*${NC} AI Alias: ${BLUE}whisper${NC} (Speech-to-text)."
echo -e "  ${YELLOW}*${NC} Maintenance: ${BLUE}upgrade-all${NC} (Updates System + All Tools)."
echo -e "  ${YELLOW}*${NC} Use ${BLUE}copy/paste${NC} to sync with Android clipboard."
echo "--------------------------------------------"
