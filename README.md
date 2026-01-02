# Termux Bootstrap v2.2

A modular, safe, and mobile-optimized bootstrap script for your Termux environment. Turn a fresh Termux install into a powerful development environment in minutes.

## Features

### 🚀 Core Tools
- **Fish Shell**: Friendly interactive shell with auto-completions.
- **Git**: Distributed version control.
- **Node.js**: JavaScript runtime (LTS).
- **Gemini CLI**: Google's AI assistant directly in your terminal.

### 📦 Community Extras (New!)
- **Media Suite**: Installs `yt-dlp` (YouTube) and `spotDL` (Spotify) with **FFmpeg**.
    - *Optimized:* Automatically configures downloads to save to `/sdcard/Download/Termux` and `/sdcard/Music`.
- **Termux Whisper**: Installs [termux-whisper](https://github.com/MuathAmer/termux-whisper) for offline, privacy-focused AI speech transcription on your phone.

### 📱 Mobile Optimizations (Portrait Mode)
- **Starship (Portrait Config)**: Optional 2-line prompt optimized for narrow phone screens.
- **Micro Editor**: Touch-friendly text editor with mouse/touch support enabled by default.
- **Narrow Aliases**: Shortcuts like `gl` (git log graph) designed to fit on phone screens.
- **Clipboard Sync**: `copy` and `paste` commands to sync with Android clipboard.

### 🎨 Modern UI ("The Ricing")
- **Lsd**: The next gen `ls` command with colors and icons.
- **Bat**: A `cat` clone with syntax highlighting and Git integration.
- **Zoxide**: A smarter `cd` command that remembers your frequent directories.
- **Fzf**: Command-line fuzzy finder.
- **Glow**: Render Markdown on the CLI (used for Gemini outputs).
- **Nerd Fonts**: Automatically installs **JetBrains Mono Nerd Font** for proper icon support.

### 🛡️ Safety & Config
- **Idempotent**: Can be run multiple times without duplicating configurations.
- **Backups**: Automatically backs up files (`config.fish`, fonts) before modifying them.
- **Interactive**: Asks for confirmation before major changes (unless `-y` flag is used).
- **Uninstaller**: Includes `uninstall.sh` to revert changes and restore backups.

## Installation

### Option 1: One-Liner (Recommended)

Requires `curl`.

```bash
pkg install curl -y
bash <(curl -s https://raw.githubusercontent.com/MuathAmer/termux-bootstrap/main/setup.sh)
```

### Option 2: Clone and Run

```bash
pkg install git -y
git clone https://github.com/MuathAmer/termux-bootstrap.git
cd termux-bootstrap
chmod +x setup.sh
./setup.sh
```

### Silent Mode (No Prompts)

Ideal for automated setups.

```bash
./setup.sh -y
```

## Uninstalling

To revert changes, run the `uninstall.sh` script included in the repository:

```bash
cd termux-bootstrap
./uninstall.sh
```
This script will:
*   Remove injected configurations from `config.fish`.
*   Restore backed-up configuration files and fonts (if found).
*   Offer to uninstall installed packages and tools.
*   Revert your default shell to Bash.

## Shortcuts & Aliases

To make mobile usage easier, the following shortcuts are included:

| Alias | Command | Description |
| :--- | :--- | :--- |
| **`video`** | `yt-dlp ...` | Download video to `/sdcard/Download/Termux` |
| **`music`** | `spotdl ...` | Download Spotify songs to `/sdcard/Music` |
| **`whisper`** | `termux-whisper` | Launch the AI Transcriber |
| **`upgrade-all`** | *(Function)* | Update System, Pip, NPM, & Repos |
| `copy` | `termux-clipboard-set` | Pipe text to Android clipboard |
| `paste` | `termux-clipboard-get` | Paste from Android clipboard |
| `gl` | `git log --oneline...` | **Narrow** git log for phones |
| `c` | `clear` | Clear screen |
| `..` | `cd ..` | Go up one directory |

> **Note:** For `copy`/`paste` to work, you must have the [Termux:API](https://f-droid.org/en/packages/com.termux.api/) app installed on your Android device.

## Post-Install Guide

1.  **Restart Termux** to load the new settings.
2.  **Configure Gemini**: `gemini configure` (Requires API Key).
3.  **Try the Extras**:
    *   `video "https://youtube.com/watch?v=..."`
    *   `music "https://open.spotify.com/track/..."`

## Credits

- Inspired by [termux-fish](https://github.com/msn-05/termux-fish).
- Uses [Starship](https://starship.rs) and [Nerd Fonts](https://www.nerdfonts.com).
