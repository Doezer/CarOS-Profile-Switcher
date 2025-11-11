# Changelog

All notable changes to CarOS Profile Switcher will be documented in this file.

## [Unreleased]

### Added
- **🎵 Audio Streaming Feature**: Stream audio from another device to car speakers via two methods:
  - **Bluetooth A2DP Sink** (`ENABLE_BT_AUDIO_SINK`): Receive audio via Bluetooth
    - May not work if Bluetooth is used for car audio even in wired mode
    - Device becomes discoverable for pairing
    - Automatic A2DP sink mode configuration
  - **WiFi Hotspot** (`ENABLE_WIFI_AUDIO_HOTSPOT`): Create WiFi hotspot for audio streaming
    - Recommended alternative when Bluetooth is occupied by car
    - Works in WIRED mode when WiFi is not used by car
    - Configurable SSID and password
    - Requires audio streaming app on emitting device (SoundWire, AudioRelay, etc.)
  - Both methods only work in WIRED mode (USB connection)
  - Automatically disable in IDLE mode to save battery
  - Comprehensive documentation in README.md, EXAMPLES.md, and FAQ.md

### Planned
- Improved error handling in service.sh

## [0.2.3] - 2025-11-05

### Added
- **🔔 Automatic Permission Management**: New `grant_permissions.sh` script that automatically grants:
  - Notification permissions to Android Auto, Waze, Google Maps, Nova Launcher, Spotify
  - Location permissions (foreground + background) to Google Maps, Waze, Android Auto
  - Configurable via `AUTO_GRANT_PERMISSIONS` setting
  - Runs on boot and periodically every 30 minutes to ensure permissions persist
- Comprehensive documentation suite:
  - `README.md` with installation, configuration, and deployment guides
  - `EXAMPLES.md` with car-specific configurations (Audi, VW, BMW, Mercedes, etc.)
  - `FAQ.md` with frequently asked questions and troubleshooting
  - `LICENSE` (MIT License)
  - `CONTRIBUTING.md` with detailed developer guidelines
  - `.github/copilot-instructions.md` for AI-assisted development
- GitHub Actions workflows:
  - Automated release building and publishing
  - Pull request validation and version consistency checking
- Build automation:
  - `build.ps1` for PowerShell
  - `build.sh` for Bash/Linux
  - 
### Changed
- **🌍 Full English Translation**: All code, comments, and log messages translated from French to English
- Updated to modern GitHub Actions (upload-artifact@v4, action-gh-release@v2)
- Enhanced error handling and logging throughout all scripts

### Fixed
- Fixed duplicate `generate_user_config` call in `post-fs-data.sh`
- Fixed version mismatch between `module.prop` and `service.sh` log message
- Fixed duplicate `env` section in release workflow

---

## [0.2.2] - Previous Release

### Added
- WiFi smart management with configurable keep-on options
- VW Polo 6 compatibility (WiFi in wired mode)
- `KEEP_WIFI_IN_WIRED` configuration option
- `KEEP_WIFI_IN_IDLE` configuration option

### Fixed
- Configuration file creation issues
- WiFi state management in different profiles

## [0.2.2] - Previous Release

### Added
- Nova Launcher as default launcher feature
- `SET_NOVA_DEFAULT` configuration option

### Changed
- Improved launcher detection and setting

## [0.2.1] - Previous Release

### Fixed
- Configuration file handling
- Permission issues on some devices

## [0.2.0] - Initial Release

### Added
- Automatic profile switching (WIRED/WIRELESS/IDLE)
- Android Auto detection
- Bluetooth connection monitoring
- USB connection detection
- WiFi management
- Mobile data control
- CPU throttling for idle mode
- Battery saver integration
- Charge limiting in wired mode
- Configurable settings via `/sdcard/CarOS/config.env`
- Support for multiple car Bluetooth names (regex)
- MAC address matching
- Verbose logging
- Periodic health checks
- State persistence

### Features
- **WIRED Profile**: USB + Android Auto active
  - Configurable WiFi, Bluetooth, and data
  - CPU at max performance
  - Battery saver off
  - Optional charge limiting

- **WIRELESS Profile**: Bluetooth + Android Auto active
  - All radios on
  - CPU at max performance
  - Battery saver off
  - Normal charging

- **IDLE Profile**: Outside car
  - Configurable WiFi
  - Optional data disable
  - CPU throttling
  - Battery saver on

---

## Release Notes Format

Each release should include:
- Version number (semantic versioning)
- Date
- Categories: Added, Changed, Deprecated, Removed, Fixed, Security
- Brief description of each change

## Version Numbering

Format: MAJOR.MINOR.PATCH

- **MAJOR**: Incompatible API changes or major feature overhaul
- **MINOR**: New features, backward compatible
- **PATCH**: Bug fixes, backward compatible
