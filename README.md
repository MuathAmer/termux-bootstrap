# Termux Bootstrap v2.0

A modular, safe, and modern bootstrap script for your Termux environment. Turn a fresh Termux install into a powerful development environment in minutes.

## Features

### 🚀 Core Tools
- **Fish Shell**: Friendly interactive shell with auto-completions.
- **Git**: Distributed version control.
- **Node.js**: JavaScript runtime (LTS).
- **Gemini CLI**: Google's AI assistant directly in your terminal.

### 🎨 Modern UI ("The Ricing")
- **Starship**: Fast, customizable, and beautiful cross-shell prompt.
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

## Post-Install Guide

1.  **Restart Termux** to load the new font and shell settings.
2.  **Configure Gemini**:
    Run the following command (you need an API key from [Google AI Studio](https://aistudio.google.com/)):
    ```bash
    gemini configure
    ```
3.  **Try the new commands**:
    *   `ask "How do I reverse a string in Python?"` (AI Assistance)
    *   `z termux` (Smart jump to directories)
    *   `ls` (See the new icons)
    *   `cat README.md` (See syntax highlighting)

## Mobile Shortcuts & Helpers

To make typing easier on touchscreens, the following shortcuts are included:

| Alias | Command | Description |
| :--- | :--- | :--- |
| `c` | `clear` | Clear the terminal screen |
| `..` / `...` | `cd ..` | Navigate up directories |
| `g` | `git` | Git command |
| `up` | `pkg update...` | Update and upgrade packages |
| `in` | `pkg install` | Install a new package |
| `copy` | `termux-clipboard-set` | Pipe text to Android clipboard |
| `paste` | `termux-clipboard-get` | Paste from Android clipboard |

> **Note:** For `copy`/`paste` to work, you must have the [Termux:API](https://f-droid.org/en/packages/com.termux.api/) app installed on your Android device.

## Credits

- Inspired by [termux-fish](https://github.com/msn-05/termux-fish).
- Uses [Starship](https://starship.rs) and [Nerd Fonts](https://www.nerdfonts.com).