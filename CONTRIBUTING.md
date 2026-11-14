# Contributing to CarOS Profile Switcher

Thank you for your interest in contributing! This guide will help you understand the project structure and development workflow.

## 📁 Project Structure

```
caros-profile-switcher/
├── build.ps1                # PowerShell build script
├── build.sh                 # Bash build script
├── caros_config.sh          # Central configuration with defaults
├── grant_permissions.sh     # Automatic permission management
├── module.prop              # Magisk module metadata
├── post-fs-data.sh          # Early boot initialization
├── service.sh               # Main service loop (runs continuously)
├── system.prop              # System property overrides
├── .gitignore               # Git ignore rules
├── README.md                # Main documentation
├── CHANGELOG.md             # Version history
├── CONTRIBUTING.md          # This file
├── META-INF/                # Magisk installer
│   └── com/google/android/
│       ├── update-binary    # Magisk installation script
│       └── updater-script   # Magisk marker file
└── rel/                     # Build output directory (ignored by git)
```

## 🔧 Development Setup

### Prerequisites
- Text editor (VS Code recommended)
- PowerShell or Bash for building
- Android device with Magisk for testing
- ADB tools for debugging

### Getting Started
1. Clone the repository
2. Make your changes
3. Test on your device
4. Build a release
5. Submit a pull request

## 🛠️ Key Components

### caros_config.sh
- Contains all default configuration values
- Provides `generate_user_config()` function
- Provides `apply_defaults()` function
- Sourced by both `post-fs-data.sh` and `service.sh`

### grant_permissions.sh
- Grants notification permissions to Android Auto, Waze, Maps, Nova, Spotify
- Grants location permissions (including background) to Maps, Waze, Android Auto
- Runs on boot and periodically (every 30 minutes)
- Configurable via `AUTO_GRANT_PERMISSIONS` setting

### post-fs-data.sh
- Runs early in boot process
- Creates configuration file if missing
- Sets up directory structure
- Ensures proper permissions

### service.sh
- Main service loop (runs every 3 seconds)
- Detects connection state (WIRED/WIRELESS/IDLE)
- Applies appropriate profiles
- Manages device resources
- Logs state changes

## 📝 Making Changes

### Before You Code
1. Check existing issues for similar work
2. Create an issue to discuss major changes
3. Update CHANGELOG.md for your changes

### Coding Standards
- Use clear, descriptive variable names
- Add comments for complex logic
- Follow existing shell script style
- Test thoroughly before committing

### Testing Your Changes
1. Build the module: `./build.ps1` or `./build.sh`
2. Install via Magisk Manager
3. Reboot your device
4. Check logs: `adb shell cat /data/adb/caros/log.txt`
5. Verify state changes work correctly

## 🔄 Release Process

### 1. Update Version Numbers
Edit `module.prop`:
```properties
version=X.Y.Z          # Update version
versionCode=N          # Increment by 1
description=...        # Add changelog summary
```

Edit `service.sh` (around line 257):
```bash
log "CarOS Profile Switcher service vX.Y.Z started"
```

### 2. Update Documentation
- Add entry to `CHANGELOG.md`
- Update `README.md` if needed
- Document any new configuration options

### 3. Build Release
```powershell
# PowerShell
.\build.ps1

# Or Bash
./build.sh
```

### 4. Test Release
- Install the generated ZIP via Magisk
- Test all profiles (WIRED/WIRELESS/IDLE)
- Check logs for errors
- Verify new features work

### 5. Commit and Tag
```bash
git add .
git commit -m "Release vX.Y.Z: Brief description"
git tag vX.Y.Z
git push origin main --tags
```

## 🐛 Debugging Tips

### Enable Verbose Logging
In `/data/adb/caros/config.env`:
```bash
VERBOSE=1
```

### View Logs
```bash
# Full log
adb shell cat /data/adb/caros/log.txt

# Last 50 lines
adb shell tail -n 50 /data/adb/caros/log.txt

# Follow in real-time
adb shell tail -f /data/adb/caros/log.txt

# Check current state
adb shell cat /data/adb/caros/state.json
```

### Common Issues
- **Module not loading**: Check Magisk version (needs 20.4+)
- **Profiles not switching**: Enable verbose logging and check BT/USB detection
- **Permission errors**: Verify SELinux isn't blocking operations

## 📋 Checklist for Pull Requests

- [ ] Code follows existing style
- [ ] Version numbers updated in all files
- [ ] CHANGELOG.md updated
- [ ] Tested on actual device
- [ ] No errors in logs
- [ ] Documentation updated (if needed)
- [ ] Commit message is clear and descriptive

## 🎯 Areas for Contribution

### High Priority
- Support for more car systems (BMW, Mercedes, etc.)
- Better charge limiting detection
- Auto-rotation management
- Screen brightness control

### Nice to Have
- Web-based configuration UI
- Profile scheduling (time-based rules)
- Multiple car profiles
- Integration with Tasker/Automate

### Documentation
- Video tutorials
- More troubleshooting guides
- Translations
- FAQ section

## 💡 Feature Requests

Have an idea? Open an issue with:
- Clear description of the feature
- Use case / why it's needed
- Example configuration (if applicable)
- Any implementation ideas

## 🤝 Code of Conduct

- Be respectful and professional
- Test before submitting
- Document your changes
- Help others learn
- Have fun! 🚗

## 📫 Contact

For questions or discussions:
- Open an issue on GitHub
- Include logs if reporting bugs
- Be patient - this is maintained in free time

---

**Happy coding and safe driving! 🚗💨**
