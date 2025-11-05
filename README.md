[![Build and Release](https://github.com/Doezer/CarOS-Profile-Switcher/actions/workflows/release.yml/badge.svg)](https://github.com/Doezer/CarOS-Profile-Switcher/actions/workflows/release.yml)

# CarOS Profile Switcher

A Magisk module for Android that automatically switches device profiles based on Android Auto connection state (wired/wireless) and intelligently manages device resources for in-car use.

## 🚗 Features

### Automatic Profile Switching
- **WIRED Mode**: Activated when USB is connected AND Android Auto is running
- **WIRELESS Mode**: Activated when Bluetooth is connected to your car AND Android Auto is running  
- **IDLE Mode**: Activated when not in car (battery saving mode)

### Intelligent Resource Management
- **WiFi Control**: Keep WiFi on/off in wired/idle modes (useful for VW Polo 6 compatibility)
- **Mobile Data Management**: Automatically enable/disable mobile data based on mode
- **Bluetooth Control**: Smart BT management in wired mode
- **CPU Throttling**: Limit CPU frequency when idle to save battery
- **Charge Limiting**: Reduce fast charging in wired mode to prevent overheating
- **Battery Saver**: Automatically enable when not in car
- **Nova Launcher**: Set as default launcher automatically
- **🔔 Auto Permissions**: Automatically grants notification and location permissions to Android Auto, Waze, Google Maps, and Nova Launcher

### Configuration
- User-configurable via `/sdcard/CarOS/config.env`
- Supports multiple car Bluetooth names (regex patterns)
- MAC address matching support
- Verbose logging for troubleshooting
- **📚 See [EXAMPLES.md](EXAMPLES.md) for car-specific configurations**

## 📋 Requirements

- **Android device** with root access
- **Magisk** v20.4 or higher
- **Android Auto** app installed
- *Optional*: Nova Launcher (for launcher switching feature)

## 🔧 Installation

1. Download the latest release ZIP from the `rel/` directory or [releases page]
2. Open Magisk Manager
3. Go to **Modules** → **Install from storage**
4. Select the downloaded ZIP file
5. Reboot your device

## ⚙️ Configuration

After installation, edit the configuration file at `/sdcard/CarOS/config.env`:

> 💡 **Quick Start**: See [EXAMPLES.md](EXAMPLES.md) for ready-to-use configurations for Audi, VW, BMW, Mercedes, and more!

```bash
# Car Bluetooth name(s) - supports regex (e.g., "Audi|VW|Volkswagen")
AUDI_BT_NAMES="Audi"

# Optional: Match by MAC address instead
AUDI_BT_MAC=""

# Wired mode: Keep Bluetooth on (1) or off (0)
ALLOW_BT_IN_WIRED=1

# Mobile data management
DATA_OFF_OUTSIDE=1        # Disable data when idle
KEEP_DATA_IN_CAR=1        # Keep data on in car (for Waze/Spotify)

# CPU throttling when idle (in kHz, e.g., 1516800 = ~1.5 GHz)
IDLE_MAX_CPU_FREQ=""

# Limit fast charging in wired mode (reduces heat)
LIMIT_QUICK_CHARGE_WIRED=1

# Set Nova Launcher as default
SET_NOVA_DEFAULT=1

# WiFi management
KEEP_WIFI_IN_WIRED=1      # Keep WiFi on in wired mode (VW Polo 6, etc.)
KEEP_WIFI_IN_IDLE=1       # Keep WiFi on when idle

# Automatic permission management
AUTO_GRANT_PERMISSIONS=1  # Auto-grant notifications & location to AA, Waze, Maps

# Verbose logging
VERBOSE=1
```

## 📝 How It Works

1. **Boot**: The module starts automatically via `service.sh`
2. **Permissions**: Automatically grants notification and location permissions to critical apps (Android Auto, Waze, Google Maps, Nova Launcher)
3. **Monitoring**: Every 3 seconds, the module checks:
   - USB connection status
   - Bluetooth connection to configured car device
   - Android Auto process state
3. **Profile Application**: When state changes, applies appropriate profile:

### Profile Details

| Profile | WiFi | Bluetooth | Mobile Data | CPU | Battery Saver | Charging |
|---------|------|-----------|-------------|-----|---------------|----------|
| **WIRED** | Configurable | Configurable | Configurable | Max | Off | Limited* |
| **WIRELESS** | On | On | Configurable | Max | Off | Normal |
| **IDLE** | Configurable | N/A | Off* | Limited* | On | Normal |

*\*Configurable via config file*

## 📦 Building a New Release

### Quick Build (PowerShell)

```powershell
# Set version number
$VERSION = "0.2.4"

# Create release directory if it doesn't exist
New-Item -ItemType Directory -Force -Path "rel"

# Create the ZIP file (from project root)
Compress-Archive -Path "caros_config.sh", "module.prop", "post-fs-data.sh", "service.sh", "system.prop", "grant_permissions.sh", "META-INF" -DestinationPath "rel/CarOS_Profile_Switcher-v$VERSION.zip" -Force

Write-Host "Release created: rel/CarOS_Profile_Switcher-v$VERSION.zip"
```

### Manual Build Steps

1. **Update Version Numbers**:
   ```bash
   # Edit module.prop
   version=0.2.4
   versionCode=5  # Increment by 1
   description=... # Update changelog
   ```

2. **Update Service Script Version**:
   ```bash
   # Edit service.sh (around line 257)
   log "CarOS Profile Switcher service v0.2.4 started"
   ```

3. **Create ZIP Archive**:
   Include these files/directories:
   - `caros_config.sh`
   - `module.prop`
   - `post-fs-data.sh`
   - `service.sh`
   - `system.prop`
   - `grant_permissions.sh`
   - `META-INF/` (entire directory)

4. **Name Convention**:
   ```
   CarOS_Profile_Switcher-v{VERSION}.zip
   ```
   Example: `CarOS_Profile_Switcher-v0.2.4.zip`

5. **Save to Release Directory**:
   ```powershell
   # Move to rel/ directory
   Move-Item "CarOS_Profile_Switcher-v0.2.4.zip" "rel/"
   ```

### Using Git Bash (Alternative)

```bash
#!/bin/bash
VERSION="0.2.4"
mkdir -p rel
zip -r "rel/CarOS_Profile_Switcher-v${VERSION}.zip" \
    caros_config.sh \
    module.prop \
    post-fs-data.sh \
    service.sh \
    system.prop \
    grant_permissions.sh \
    META-INF
echo "Release created: rel/CarOS_Profile_Switcher-v${VERSION}.zip"
```

## 🐛 Troubleshooting

> 💡 **Tip**: Check the [FAQ.md](FAQ.md) for common issues and solutions!

### Check Logs
View module logs:
```bash
adb shell cat /data/adb/modules/caros-switcher/log.txt
```

### Check Current State
```bash
adb shell cat /data/adb/modules/caros-switcher/state.json
```

### Common Issues

**Module not working:**
- Ensure Magisk is properly installed
- Check that Android Auto is installed
- Verify Bluetooth name in config matches your car

**Bluetooth not detected:**
- Enable verbose logging (`VERBOSE=1`)
- Check logs for Bluetooth dump
- Try using MAC address instead of name

**WiFi/Data not switching:**
- Some Android versions have restricted APIs
- Check logs for error messages
- May require additional permissions/SELinux changes

## 📄 Files Structure

```
caros-profile-switcher/
├── build.ps1                # PowerShell build script
├── build.sh                 # Bash build script
├── caros_config.sh          # Central configuration defaults
├── grant_permissions.sh     # Automatic permission management
├── module.prop              # Magisk module metadata
├── post-fs-data.sh          # Early boot initialization
├── service.sh               # Main service loop
├── system.prop              # System property overrides
├── README.md                # This file
├── CHANGELOG.md             # Version history
├── CONTRIBUTING.md          # Developer guide
├── EXAMPLES.md              # Configuration examples
├── LICENSE                  # MIT License
├── .gitignore               # Git ignore rules
├── META-INF/                # Magisk installer
│   └── com/google/android/
│       ├── update-binary    # Installation script
│       └── updater-script   # Magisk marker
└── rel/                     # Release builds (not in repo)
```

## 🔄 Version History

- **v0.2.3**: WiFi smart management + VW Polo 6 compatible + bug fixes
- **v0.2.2**: Nova Launcher default setting
- **v0.2.1**: Configuration fixes
- **v0.2.0**: Initial release with profile switching

See [CHANGELOG.md](CHANGELOG.md) for detailed version history.

## 📚 Documentation

- **[README.md](README.md)** - Main documentation (you are here)
- **[EXAMPLES.md](EXAMPLES.md)** - Car-specific configuration examples
- **[FAQ.md](FAQ.md)** - Frequently asked questions
- **[CONTRIBUTING.md](CONTRIBUTING.md)** - Developer guide
- **[CHANGELOG.md](CHANGELOG.md)** - Version history

## 📜 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 👤 Authors

- Vincent Airiau - [GitHub](https://github.com/Doezer)

## 🙏 Acknowledgments

- Magisk community for the module framework
- Android Auto developers

---

**Note**: This module requires root access and modifies system behavior. Use at your own risk. Always test in a safe environment first.
