# GitHub Copilot Instructions for CarOS Profile Switcher

## Project Overview
CarOS Profile Switcher is a Magisk module for Android that automatically manages device profiles based on Android Auto connection state (wired/wireless/idle). It optimizes device resources for in-car use.

## Code Style & Standards

### Shell Scripting (Bash/sh)
- Use POSIX-compliant shell script syntax
- All comments and documentation must be in **English only**
- Use descriptive variable names in UPPERCASE for constants: `DEFAULT_SETTING_NAME`
- Use lowercase for local variables: `local_variable`
- Always include error handling with `|| error_log` or fallback commands
- Use `2>/dev/null` to suppress expected errors
- Prefer `[ ]` over `[[ ]]` for better POSIX compatibility

### Commenting
- Add comments for complex logic
- Document function purposes with brief descriptions
- Use inline comments to explain non-obvious behavior
- Example:
  ```bash
  # Check with error handling
  if usb_connected && aa_process_active; then
  ```

### Logging
- Use `log()` for informational messages
- Use `error_log()` for errors
- Use `vlog()` for verbose/debug messages
- Always include timestamps (handled by log functions)
- Format: `log "Clear message describing what happened"`

## Architecture

### File Structure
- **caros_config.sh**: Centralized configuration, all defaults, generates user config
- **post-fs-data.sh**: Early boot initialization, creates directories, sets permissions
- **service.sh**: Main service loop, runs continuously, monitors state changes
- **grant_permissions.sh**: Manages app permissions (notifications, location)
- **module.prop**: Magisk module metadata
- **system.prop**: System property overrides

### Key Concepts

#### Profile States
1. **WIRED**: USB connected + Android Auto running
2. **WIRELESS**: Bluetooth connected to car + Android Auto running
3. **IDLE**: Not in car (default state)

#### Configuration Flow
1. Defaults defined in `caros_config.sh` (`DEFAULT_*` variables)
2. User config at `/sdcard/CarOS/config.env` (generated from defaults)
3. `apply_defaults()` ensures all variables have values

#### Service Loop
- Runs every 3 seconds
- Caches Bluetooth/Android Auto checks to reduce overhead
- State changes trigger profile applications
- Periodic health checks (every 100 loops)
- Periodic permission re-grants (every 600 loops / ~30 minutes)

## Common Patterns

### Adding New Configuration Options

1. Add default in `caros_config.sh`:
   ```bash
   # Feature description (what it does)
   DEFAULT_NEW_FEATURE=1
   ```

2. Add to `generate_user_config()`:
   ```bash
   # Feature description (what it does)
   NEW_FEATURE=$DEFAULT_NEW_FEATURE
   ```

3. Add to `apply_defaults()`:
   ```bash
   : "${NEW_FEATURE:=$DEFAULT_NEW_FEATURE}"
   ```

4. Document in README.md configuration section

### Adding New Functions

```bash
function_name(){
  # Brief description of what function does
  local variable="value"
  
  # Check conditions with error handling
  if some_command 2>/dev/null; then
    log "Success message"
    return 0
  fi
  
  error_log "Failure message"
  return 1
}
```

### Error Handling Pattern
```bash
# Try primary method, fall back to alternatives
cmd primary_method 2>/dev/null || alternative_method 2>/dev/null || {
  error_log "All methods failed for feature X"
}
```

### Caching Pattern
```bash
check_with_cache(){
  # Cache to avoid repeated calls
  if [ -n "$CACHE_VAR" ] && [ $(($(date +%s) - CACHE_TIME)) -lt SECONDS ]; then
    [ "$CACHE_VAR" = "1" ] && return 0 || return 1
  fi
  
  CACHE_TIME=$(date +%s)
  # Perform actual check
  if actual_check; then
    CACHE_VAR=1
    return 0
  fi
  
  CACHE_VAR=0
  return 1
}
```

## Android-Specific Guidelines

### Permission Management
- Always check if app is installed before granting permissions
- Use `pm grant` for runtime permissions
- Use `appops set` for app operations
- Use `cmd notification` for notification access
- Suppress errors for apps that aren't installed

### System Commands
- `dumpsys`: Query system services (bluetooth_manager, usb, activity)
- `pm`: Package manager operations
- `cmd`: Direct service commands (wifi, bluetooth, notification)
- `svc`: Legacy service control (wifi, data, bluetooth)
- `settings`: Read/write system settings
- `appops`: App operations management

### Path Conventions
- Module files: `/data/adb/modules/caros-switcher/`
- User config: `/sdcard/CarOS/config.env`
- Logs: `/data/adb/modules/caros-switcher/log.txt`
- State: `/data/adb/modules/caros-switcher/state.json`

## Testing & Validation

### Before Committing
1. Validate shell syntax: `bash -n script.sh`
2. Test on actual device (if possible)
3. Check logs for errors: `adb shell cat /data/adb/modules/caros-switcher/log.txt`
4. Verify version consistency across files

### Log Analysis
- Look for `[ERROR]` messages
- Check state transitions: "State change: X -> Y"
- Verify periodic "Service alive" messages
- Check "[PERMS]" messages for permission grants

## Build Process

### Version Updates
Update in 3 places:
1. `module.prop`: `version=X.Y.Z` and `versionCode=N`
2. `service.sh`: `log "CarOS Profile Switcher service vX.Y.Z started"`
3. `caros_config.sh`: Header comment version

### Creating Release
```bash
# PowerShell
.\build.ps1

# Bash
./build.sh
```

### Files to Include in ZIP
- caros_config.sh
- module.prop
- post-fs-data.sh
- service.sh
- system.prop
- grant_permissions.sh
- META-INF/ (directory with installer)

## Documentation

### When Adding Features
1. Update README.md (features list, configuration example)
2. Update CHANGELOG.md (under [Unreleased])
3. Update EXAMPLES.md if relevant
4. Update FAQ.md for common questions
5. Update CONTRIBUTING.md if architecture changes

### Code Comments
- **English only** - no French
- Be concise but clear
- Explain "why" not just "what"
- Document workarounds and limitations

## Common Tasks

### Adding Support for New App
1. Add package name to `NOTIFICATION_APPS` or `LOCATION_APPS` in `grant_permissions.sh`
2. Test that app receives permissions
3. Document in README/FAQ

### Adding New Profile State
1. Define state detection logic
2. Create `apply_<state>_profile()` function
3. Add case in main loop
4. Update documentation

### Modifying Resource Control
- WiFi: `wifi_on()` / `wifi_off()`
- Data: `data_on()` / `data_off()`
- Bluetooth: `bt_on()` / `bt_off()`
- CPU: `set_cpu_max()` / `reset_cpu_max()`
- Battery: `battery_saver_on()` / `battery_saver_off()`
- Charging: `charge_limit_on()` / `charge_limit_off()`

## Anti-Patterns (Avoid)

❌ **Don't:** Use French in comments or messages
✅ **Do:** Use English for all text

❌ **Don't:** Call expensive operations without caching
✅ **Do:** Implement caching for repeated checks

❌ **Don't:** Fail silently on errors
✅ **Do:** Log errors with `error_log()`

❌ **Don't:** Hardcode paths or values
✅ **Do:** Use variables and configuration

❌ **Don't:** Assume commands succeed
✅ **Do:** Provide fallbacks and error handling

❌ **Don't:** Block on long-running operations
✅ **Do:** Run expensive tasks in background with `&`

## Compatibility Considerations

- Support Android 10-14 (may work on others)
- POSIX shell compliance for maximum compatibility
- Multiple fallback methods for system commands
- Graceful degradation if features unavailable
- LineageOS-specific handling (delayed /sdcard mount)

## Performance

- Service loop: 3 second interval (balance responsiveness vs battery)
- Bluetooth cache: 5 seconds
- Android Auto cache: 2 seconds
- Permission re-grant: 30 minutes
- Log rotation: 1MB threshold

## Security Notes

- Module requires root (Magisk)
- Modifies system behavior (WiFi, data, Bluetooth, CPU)
- Grants permissions to apps without user interaction
- Users should review configuration before use
- All operations logged for audit trail

---

**Remember:** This is a system-level module that runs with elevated privileges. Always prioritize stability, error handling, and user safety over new features.
