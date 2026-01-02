#!/data/data/com.termux/files/usr/bin/bash

# ==============================================================================
# Termux Bootstrap v2.1
# A modular, safe, and modern setup script for Termux.
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
NC='\033[0m' # No Color

# --- Helper Functions ---

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[OK]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

prompt_confirm() {
    # If not interactive, return 0 (true/yes)
    if [ "$INTERACTIVE" = false ]; then
        return 0
    fi
    
    while true; do
        read -r -p "$1 [Y/n]: " yn
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
    log_info "Updating package lists and upgrading system..."
    pkg update -y && pkg upgrade -y
}

install_base_tools() {
    log_info "Installing base tools (Git, Fish, Node.js, Curl, Termux API)..."
    pkg install git fish nodejs-lts curl termux-api -y
}

install_modern_tools() {
    log_info "Installing modern CLI tools (Lsd, Bat, Zoxide, Fzf, Starship, Glow)..."
    pkg install lsd bat zoxide fzf starship glow -y
}

install_micro_editor() {
    log_info "Installing Micro editor..."
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
    fi
}

install_gemini() {
    if ! command -v gemini &> /dev/null; then
        log_info "Installing Google Gemini CLI..."
        npm install -g @google/gemini-cli
    else
        log_success "Gemini CLI is already installed."
    fi
}

setup_storage() {
    log_info "Requesting Termux storage access..."
    termux-setup-storage
}

install_nerd_font() {
    if [ -f "$FONT_FILE" ]; then
        log_warn "A font is already installed at $FONT_FILE."
        if ! prompt_confirm "Do you want to overwrite it with JetBrains Mono Nerd Font?"; then
            return
        fi
        backup_file "$FONT_FILE"
    fi

    log_info "Downloading JetBrains Mono Nerd Font..."
    mkdir -p "$FONT_DIR"
    # Using a reliable raw link for the font
    curl -fLo "$FONT_FILE" https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/JetBrainsMono/Ligatures/Regular/JetBrainsMonoNerdFont-Regular.ttf
    
    log_info "Reloading Termux settings to apply font..."
    termux-reload-settings
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
}

configure_fish() {
    log_info "Configuring Fish Shell..."
    mkdir -p "$CONFIG_DIR"
    
    # Define the block content
    local BLOCK_START="# --- TERMUX-BOOTSTRAP-START ---"
    local BLOCK_END="# --- TERMUX-BOOTSTRAP-END ---"
    
    # Prepare the new configuration block
    local NEW_CONFIG="
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
    if test -z \"\$argv\"
        echo \"Usage: ask 'your question'\"
        return 1
    end
    # Check if glow is installed for rendering, else plain text
    if command -q glow
        gemini \"\$argv\" | glow -
    else
        gemini \"\$argv\"
    end
end
$BLOCK_END