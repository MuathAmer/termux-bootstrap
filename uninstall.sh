#!/data/data/com.termux/files/usr/bin/bash

# ==============================================================================
# Termux Bootstrap Uninstaller
# Safely reverts changes made by the setup.sh script.
# ==============================================================================

# --- Variables ---
CONFIG_DIR="$HOME/.config/fish"
CONFIG_FILE="$CONFIG_DIR/config.fish"
STARSHIP_CONFIG_FILE="$HOME/.config/starship.toml"
MICRO_CONFIG_FILE="$HOME/.config/micro/settings.json"
YTDLP_CONFIG_FILE="$HOME/.config/yt-dlp/config"
FONT_DIR="$HOME/.termux"
FONT_FILE="$FONT_DIR/font.ttf"
WHISPER_DIR="$HOME/termux-whisper"

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
    local default_ans="$2" # "Y" or "N"
    local prompt_suffix=""
    
    if [ "$default_ans" == "N" ]; then
        prompt_suffix="[y/N]"
    else
        prompt_suffix="[Y/n]"
        default_ans="Y"
    fi

    echo ""
    while true; do
        read -r -p "$(echo -e "${CYAN}? $1 $prompt_suffix: ${NC}")" yn
        case $yn in
            [Yy]* ) return 0;;
            [Nn]* ) return 1;;
            "" ) 
                if [ "$default_ans" == "Y" ]; then return 0; else return 1; fi
                ;;
            * ) echo "Please answer yes or no.";;
        esac
    done
}

find_latest_backup() {
    local file=$1
    # Finds files named file.bak.*, sorts them, takes the last one
    ls -1 "${file}".bak.* 2>/dev/null | sort | tail -n 1
}

# --- Steps ---

revert_fish_config() {
    log_header "Revert Fish Config"
    local BLOCK_START="# --- TERMUX-BOOTSTRAP-START ---"
    local BLOCK_END="# --- TERMUX-BOOTSTRAP-END ---"

    if [ -f "$CONFIG_FILE" ]; then
        if grep -q "$BLOCK_START" "$CONFIG_FILE"; then
            log_info "Detected Bootstrap block in config.fish."
            if prompt_confirm "Remove bootstrap configuration from Fish config?"; then
                # Create safety backup just in case sed fails
                cp "$CONFIG_FILE" "${CONFIG_FILE}.uninstall.bak"
                
                # Delete the block
                sed -i "/$BLOCK_START/,/$BLOCK_END/d" "$CONFIG_FILE"
                # Remove trailing empty lines
                sed -i '${/^$/d;}' "$CONFIG_FILE"
                log_success "Fish configuration cleaned."
            fi
        else
            log_info "No bootstrap configuration found in config.fish."
        fi
    fi
}

restore_or_delete_file() {
    local file=$1
    local name=$2
    
    if [ -f "$file" ]; then
        local backup=$(find_latest_backup "$file")
        
        if [ -n "$backup" ]; then
            log_info "Found backup for $name: $(basename "$backup")"
            if prompt_confirm "Restore $name from backup?"; then
                mv "$backup" "$file"
                log_success "$name restored."
                return
            fi
        fi
        
        # If no backup or user declined restore
        if prompt_confirm "Delete $name (reset to default)?"; then
            rm "$file"
            log_success "$name deleted."
        fi
    fi
}

revert_font() {
    if [ -f "$FONT_FILE" ]; then
        log_header "Revert Font"
        log_info "Checking Font configuration..."
        restore_or_delete_file "$FONT_FILE" "Termux Font"
        termux-reload-settings
    fi
}

clean_configs() {
    log_header "Clean Configurations"
    log_info "Checking configuration files..."
    restore_or_delete_file "$STARSHIP_CONFIG_FILE" "Starship Config"
    restore_or_delete_file "$MICRO_CONFIG_FILE" "Micro Editor Config"
    restore_or_delete_file "$YTDLP_CONFIG_FILE" "yt-dlp Config"
}

uninstall_extras() {
    log_header "Uninstall Extras"
    log_info "Checking installed extras..."

    # Gemini
    if command -v gemini &> /dev/null; then
        if prompt_confirm "Uninstall Gemini CLI?"; then
            # Attempt to uninstall the optimized package, fall back to google just in case
            npm uninstall -g @mmmbuto/gemini-cli-termux || npm uninstall -g @google/gemini-cli
            log_success "Gemini CLI removed."
        fi
    fi

    # Python Tools (yt-dlp, spotdl)
    if pip show yt-dlp &> /dev/null || pip show spotdl &> /dev/null; then
        if prompt_confirm "Uninstall Media Tools (yt-dlp, spotdl)?"; then
            pip uninstall yt-dlp spotdl -y
            log_success "Media tools removed."
        fi
    fi

    # Termux Whisper
    if [ -d "$WHISPER_DIR" ]; then
        if prompt_confirm "Delete Termux Whisper directory ($WHISPER_DIR)?"; then
            rm -rf "$WHISPER_DIR"
            log_success "Termux Whisper directory removed."
        fi
    fi
}

revert_shell() {
    log_header "Revert Shell"
    local BASH_PATH=$(which bash)
    if [ "$SHELL" != "$BASH_PATH" ]; then
        if prompt_confirm "Set default shell back to Bash?"; then
            chsh -s bash
            log_success "Default shell set to Bash."
        fi
    fi
}

uninstall_packages() {
    echo -e "\n${YELLOW}============================================================${NC}"
    echo -e "${YELLOW}:: PACKAGE REMOVAL SECTION${NC}"
    echo -e "${YELLOW}============================================================${NC}"
    echo "This step uninstalls packages. Be careful if you used Termux before this script."

    # Visual Tools (Low Risk)
    if prompt_confirm "Uninstall Visual Tools (starship, lsd, bat, zoxide, fzf, glow, micro)?"; then
        pkg uninstall starship lsd bat zoxide fzf glow micro -y
        log_success "Visual tools uninstalled."
    fi

    # Core Dependencies (High Risk)
    echo -e "${RED}WARNING:${NC} Uninstalling Core Dependencies (git, fish, python, nodejs, ffmpeg, rust, build-essential) might break other things."
    echo "Only do this if you are sure you didn't have them before bootstrapping."
    if prompt_confirm "Uninstall Core Dependencies?" "N"; then
        pkg uninstall fish git python nodejs-lts ffmpeg termux-api rust binutils build-essential -y
        log_success "Core dependencies uninstalled."
    fi
}

# --- Main Execution ---

clear
echo -e "${RED}"
echo "  _    _       _           _        _ _ "
echo " | |  | |     (_)         | |      | | |"
echo " | |  | |_ __  _ _ __  ___| |_ __ _| | |"
echo " | |  | | '_ \| | '_ \/ __| __/ _\` | | |"
echo " | |__| | | | | | | | \__ \ || (_| | | |"
echo "  \____/|_| |_|_|_| |_|___/\__\__,_|_|_|"
echo "                                        "
echo "          U N I N S T A L L E R         "
echo -e "${NC}"
echo "This script will help you revert changes made by Termux Bootstrap."

revert_fish_config
clean_configs
revert_font
uninstall_extras
revert_shell
uninstall_packages

echo -e "\n${GREEN}------------------------------------------------------------------${NC}"
log_success "Uninstallation steps complete."
echo -e "${YELLOW}*${NC} Please restart Termux for all changes to take effect."
