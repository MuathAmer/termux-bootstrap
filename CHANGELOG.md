# Changelog

All notable changes to the **Termux Bootstrap (tb)** project will be documented in this file.

## [v2.7.1] - 2026-01-05
### Changed
- **CLI Split:** Separated `tb update` (Full System Update) and `tb sync` (Script Sync Only) for better control.

## [v2.7.0] - 2026-01-05
### Added
- **`tb theme`:** Introduced an interactive theme switcher with popular color schemes (Dracula, Nord, Gruvbox, Matrix).

## [v2.6.0] - 2026-01-05
### Added
- **First Run Tour:** A welcoming guide that appears on the first shell launch to help new users get started.
- **QR Code:** Added to README for instant mobile installation (Scan-to-Copy).

## [v2.5.0] - 2026-01-05
### Changed
- **CLI Manager:** Introduced `tb.sh` as the core logic engine.
- **`tb` Command:** Promoted from a cheat sheet to a full environment manager (`tb help`, `tb update`).
- **Shell Agnostic:** Core update logic is now Bash-based, allowing usage outside of Fish.
- **Deployment:** Fixed `curl | bash` compatibility for Fish/Zsh users.

## [v2.4.4] - 2026-01-05
### Fixed
- **One-Liner Persistence:** The installer now silently clones the repo if run via pipe, ensuring `uninstall.sh` and `tb update` work later.
- **Automagic `ask`:** Fixed argument parsing bugs for piped input to the AI assistant.

## [v2.4.2] - 2026-01-05
### Added
- **Smart Greeting:** Replaced empty shell greeting with a subtle `tb` reminder.
- **Mobile Aliases:** Added `open` (termux-open) and `serve` (http.server).

## [v2.4.0] - 2026-01-05
### Changed
- **Modular Architecture:** Unbundled Fish Shell from Core Utilities. Users can now choose to install dev tools without switching shells.
- **Menu UX:** Added visual hints recommending Fish for the full experience.

## [v2.3.0] - 2026-01-05
### Added
- **"Set & Forget" Installer:** Replaced step-by-step prompts with a single interactive menu at the start.
- **Wake Lock:** Script now prevents device sleep during installation.
- **Smart Notifications:** Vibrates and sends a Toast message upon completion (Success/Failure).

## [v2.2.2] - 2026-01-05
### Fixed
- **Font Rendering:** Switched to "No Ligatures" Nerd Font to prevent terminal freezing on some Android devices.
- **Media Suite:** Moved to end of setup and increased timeout to 20m to handle compilation on slow devices.

## [v2.0.0] - Initial Release
- **Core:** Git, Node, Fish, Micro.
- **UI:** Starship, Lsd, Bat.
- **AI:** Gemini CLI integration.
