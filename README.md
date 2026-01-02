# Termux Bootstrap

This repository contains a simple script to bootstrap a new Termux environment with essential tools.

## Features

- Updates and upgrades Termux packages.
- Installs **Git**.
- Installs **Fish Shell**.
- Installs **Node.js** (required for Gemini).
- Installs **Gemini CLI** (`@google/gemini-cli`).
- Requests **Termux Storage Access**.

## Usage

### Option 1: Clone and Run (Requires Git)

If you already have `git` installed:

```bash
git clone https://github.com/YOUR_USERNAME/termux-bootstrap.git
cd termux-bootstrap
chmod +x setup.sh
./setup.sh
```

### Option 2: One-Liner (Requires Curl)

If you don't have `git` but have `curl`:

```bash
pkg install curl -y
bash <(curl -s https://raw.githubusercontent.com/YOUR_USERNAME/termux-bootstrap/main/setup.sh)
```

## After Installation

- Type `fish` to enter the Fish shell.
- Type `gemini` to start using the Gemini AI assistant.
