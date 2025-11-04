# Changelog

All notable changes to CarOS Profile Switcher will be documented in this file.

## [Unreleased]

### Added
- **🔔 Automatic Permission Management**: New `grant_permissions.sh` script that automatically grants:
  - Notification permissions to Android Auto, Waze, Google Maps, Nova Launcher, Spotify
  - Location permissions (foreground + background) to Google Maps, Waze, Android Auto
  - Configurable via `AUTO_GRANT_PERMISSIONS` setting
  - Runs on boot and periodically every 30 minutes to ensure permissions persist
- Comprehensive documentation suite:
  - `EXAMPLES.md` with car-specific configurations (Audi, VW, BMW, Mercedes, etc.)
  - `FAQ.md` with frequently asked questions and troubleshooting
  - `LICENSE` (MIT License)
  - Enhanced `CONTRIBUTING.md` with detailed guidelines
- GitHub Actions workflows:
  - Automated release building and publishing
  - Pull request validation and testing
  - Version consistency checking
- GitHub issue templates:
  - Bug report template
  - Feature request template
  - Car compatibility report template
- Improved `.gitignore` with comprehensive exclusions

### Changed
- README now links to documentation files for better navigation
- Updated license section to reference LICENSE file
- Enhanced file structure documentation

## [0.2.3] - 2025-11-04

### Fixed
- Fixed duplicate `generate_user_config` call in `post-fs-data.sh`
- Fixed version mismatch between `module.prop` and `service.sh` log message

### Added
- Comprehensive README.md with full documentation
- Build scripts for PowerShell (`build.ps1`) and Bash (`build.sh`)
- `.gitignore` to exclude build artifacts
- This CHANGELOG.md file

### Changed
- Improved documentation for deployment process

---

## [0.2.3] - Previous Release

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
