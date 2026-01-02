#!/data/data/com.termux/files/usr/bin/bash

# Termux Bootstrap Script

echo "[-] Updating package lists and upgrading existing packages..."
pkg update -y && pkg upgrade -y

echo "[-] Installing essential packages (git, fish, nodejs)..."
pkg install git fish nodejs -y

echo "[-] Setting up Termux storage access..."
echo "    (You may need to grant permission in the popup)"
termux-setup-storage

echo "[-] Installing Gemini CLI..."
npm install -g @google/gemini-cli

echo "[-] Configuration complete!"
echo "    Type 'fish' to start the fish shell."
echo "    Type 'gemini' to start the Gemini CLI."
