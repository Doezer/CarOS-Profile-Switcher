# Frequently Asked Questions (FAQ)

## General Questions

### What is CarOS Profile Switcher?
A Magisk module that automatically switches your Android device's settings based on whether you're using Android Auto (wired or wireless) or not in your car.

### Do I need root access?
Yes, this module requires:
- Rooted Android device
- Magisk v20.4 or higher installed

### Will this void my warranty?
Rooting your device and installing Magisk modules may void your warranty. Use at your own risk.

### Does this work with all Android versions?
Tested on Android 10-14. Some features may not work on older/newer versions due to API changes.

---

## Installation & Setup

### Where do I download the module?
Download the latest ZIP from:
1. The `rel/` directory in this repository
2. GitHub Releases page (recommended)
3. Build it yourself using `build.ps1` or `build.sh`

### How do I install?
1. Download the ZIP file
2. Open Magisk Manager app
3. Tap **Modules** tab
4. Tap **Install from storage**
5. Select the ZIP file
6. Reboot when prompted

### The module isn't working after installation
Check these:
1. Magisk version is 20.4 or higher
2. Android Auto app is installed
3. You've paired your car via Bluetooth
4. Module is enabled in Magisk Manager
5. Check logs: `adb shell cat /data/adb/modules/caros-switcher/log.txt`

### Where is the configuration file?
`/sdcard/CarOS/config.env`

The module creates this automatically on first boot. You can edit it with any text editor.

### Do I need to reboot after changing config?
No! The configuration is reloaded automatically. Just connect to your car and the changes take effect.

---

## Configuration Questions

### How do I find my car's Bluetooth name?
**Method 1 (easiest):**
1. Go to Settings > Bluetooth
2. Look at paired devices
3. Your car's name is listed there

**Method 2 (using logs):**
1. Set `VERBOSE=1` in config
2. Connect to your car
3. Check logs for Bluetooth device names

See [EXAMPLES.md](EXAMPLES.md) for more details.

### My car's Bluetooth name keeps changing!
Some cars append numbers or change names. Use MAC address matching instead:
```bash
AUDI_BT_MAC="AA:BB:CC:DD:EE:FF"  # Your car's MAC address
```

### Can I use this with multiple cars?
Yes! Use regex patterns:
```bash
AUDI_BT_NAMES="Audi|BMW|Rental"
```

### What if my car name has special characters?
Escape them with backslashes:
```bash
AUDI_BT_NAMES="Car \\(2024\\)|John's Car"
```

---

## Feature Questions

### Does this work with wireless Android Auto?
Yes! It detects both wired (USB) and wireless (Bluetooth) Android Auto connections.

### What is automatic permission management?
The module automatically grants necessary permissions to critical apps:
- **Notification permissions**: Android Auto, Waze, Google Maps, Nova Launcher, Spotify
- **Location permissions**: Google Maps, Waze, Android Auto (including background location)

This fixes the common issue where Android Auto requests permissions on every connection. Permissions are granted on boot and re-checked every 30 minutes.

### Can I disable automatic permission management?
Yes, set `AUTO_GRANT_PERMISSIONS=0` in your config file:
```bash
AUTO_GRANT_PERMISSIONS=0
```

### Why does Android Auto keep asking for permissions?
If you have `AUTO_GRANT_PERMISSIONS=0` or the module just installed, you may need to manually grant permissions once, or enable the automatic permission feature.

### Why isn't WiFi turning off/on?
Some Android versions restrict WiFi control. Check:
1. No battery optimization for system apps
2. Check logs for error messages
3. Try toggling `KEEP_WIFI_IN_WIRED` setting

### Battery saver isn't enabling automatically
Some devices don't allow apps to enable battery saver. This is an Android restriction on newer versions.

### Can I customize CPU throttling?
Yes! Set `IDLE_MAX_CPU_FREQ` in kHz:
```bash
IDLE_MAX_CPU_FREQ="1516800"  # ~1.5 GHz
```
Leave empty to disable CPU throttling.

### What's the "charge limiting" feature?
In wired mode, the module tries to reduce fast charging to prevent phone overheating during long drives. This is "best effort" and may not work on all devices.

### Does Nova Launcher need to be installed?
No. If `SET_NOVA_DEFAULT=1` but Nova isn't installed, the module just skips this step. No errors.

### How does audio streaming work?
CarOS supports two methods for streaming audio from another phone:

**Method 1: Bluetooth A2DP Sink**
When `ENABLE_BT_AUDIO_SINK=1`, your CarOS phone becomes discoverable and can receive audio from another phone via Bluetooth.

**Limitation:** May not work if Bluetooth is already used for car audio/calls, even in wired mode.

**Method 2: WiFi Hotspot (Recommended)**
When `ENABLE_WIFI_AUDIO_HOTSPOT=1`, your CarOS device creates a WiFi hotspot that other devices can connect to for streaming audio.

**Advantages:** Works even when Bluetooth is used by the car. Requires an audio streaming app on the emitting phone.

**To use WiFi hotspot:**
1. Enable in config: `ENABLE_WIFI_AUDIO_HOTSPOT=1`
2. Set SSID and password: `WIFI_AUDIO_HOTSPOT_SSID="CarOS-Audio"`
3. Connect to car via USB (wired mode)
4. Emitting phone connects to WiFi hotspot
5. Use audio streaming app (SoundWire, AudioRelay, etc.)

### Does Bluetooth audio sink work on all devices?
No, it's device-dependent. Some Android devices don't support A2DP sink mode. Additionally, even in wired mode, many cars use Bluetooth for audio and phone calls, which prevents the phone from acting as an A2DP sink simultaneously.

**If Bluetooth doesn't work:** Use the WiFi hotspot method instead (`ENABLE_WIFI_AUDIO_HOTSPOT=1`).

### Why isn't my phone discoverable for Bluetooth audio?
If `ENABLE_BT_AUDIO_SINK=1` but your phone isn't discoverable:
1. **Bluetooth may be in use by the car** - Even in wired mode, many cars use Bluetooth for audio/calls
2. **Try WiFi hotspot instead** - Set `ENABLE_WIFI_AUDIO_HOTSPOT=1`
3. Check that you're in WIRED mode (USB connection)
4. Look for "BT Audio Sink" messages in logs
5. Your device may not support A2DP sink mode

### Can I use audio streaming in IDLE mode?
No, both features are automatically disabled in IDLE mode to save battery. They only work when connected to your car in WIRED mode.

### Can I use audio streaming in WIRELESS mode?
No, in wireless mode both Bluetooth and WiFi are typically used by the car for Android Auto connection. The audio streaming features only work in WIRED mode where the car connection is via USB.

### What audio streaming apps work with WiFi hotspot?
Popular options include:
- **SoundWire** (free) - Low latency audio streaming
- **AudioRelay** (free) - WiFi/USB audio streaming
- **AirMusic** - DLNA/UPnP streaming
- Any app that supports streaming to a WiFi network

---

## Troubleshooting

### Module not detecting Android Auto
Check:
1. Android Auto app is installed and running
2. You're connected to your car (USB or Bluetooth)
3. Enable `VERBOSE=1` and check logs
4. Verify process name: `pidof com.google.android.projection.gearhead`

### Profiles not switching
1. Check logs: `adb shell cat /data/adb/modules/caros-switcher/log.txt`
2. Verify Bluetooth name matches: `AUDI_BT_NAMES="Your Car Name"`
3. Try MAC address matching instead
4. Ensure Android Auto is actually running (not just connected)

### "Permission denied" errors in logs
Some features require specific permissions:
- WiFi/Bluetooth control: Usually works
- Battery saver: May be restricted on Android 12+
- CPU frequency: Requires kernel support

These are best-effort features. Some may not work on all devices.

### Logs show "dumpsys failed"
This usually means:
1. Running on older Android version
2. SELinux blocking access (rare with Magisk)
3. System service isn't running

Try rebooting. If persists, the module will use fallback detection methods.

### Battery draining faster
Check your configuration:
1. `DATA_OFF_OUTSIDE=1` (disable data when idle)
2. `KEEP_WIFI_IN_IDLE=0` (disable WiFi when idle)
3. Set `IDLE_MAX_CPU_FREQ` to throttle CPU
4. Ensure `VERBOSE=0` (verbose logging uses more battery)

### Phone getting hot in car
This is normal during Android Auto use. The module tries to help:
1. `LIMIT_QUICK_CHARGE_WIRED=1` reduces charging heat
2. Ensure good phone ventilation in car
3. Consider a phone mount with cooling

---

## Advanced Questions

### Can I edit the module scripts directly?
Yes, but changes will be lost on module updates. Better to:
1. Fork the repository
2. Make your changes
3. Build your own version
4. Consider contributing back via pull request

### Where are the module files located?
```
/data/adb/modules/caros-switcher/     # Module directory
/data/adb/modules/caros-switcher/log.txt  # Logs
/data/adb/modules/caros-switcher/state.json  # Current state
/sdcard/CarOS/config.env               # User configuration
```

### How do I uninstall?
1. Open Magisk Manager
2. Go to **Modules**
3. Tap **Remove** on CarOS Profile Switcher
4. Reboot

Configuration file at `/sdcard/CarOS/` will remain (delete manually if desired).

### Can I pause the module temporarily?
Yes:
1. Open Magisk Manager
2. Disable the module
3. Reboot

Or keep enabled but set conservative settings.

### How much battery does the module use?
Minimal. The service checks every 3 seconds, which uses negligible battery. Most battery usage comes from Android Auto itself, not this module.

### What's the loop count in logs?
```
Service alive, loop #300
```
This appears every ~5 minutes (100 loops × 3 seconds) to prove the service is running. It's normal.

---

## Compatibility

### Does this work on LineageOS?
Yes! Tested and working. The module includes specific handling for LineageOS's delayed `/sdcard` mounting.

### Does this work on Samsung devices?
Should work, but Samsung's One UI has aggressive battery optimization. You may need to:
1. Disable battery optimization for system services
2. Add Magisk to "Never sleeping apps"
3. Disable "Adaptive battery"

### Does this work on Pixel devices?
Yes, well-tested on Pixel devices.

### Does this work with aftermarket head units?
Yes! As long as the head unit supports Android Auto (wired or wireless), this module will work. You just need to configure the Bluetooth name correctly.

---

## Performance & Safety

### Is this safe to use while driving?
Yes. The module:
- Runs in background
- Doesn't interrupt Android Auto
- Automatically turns screen off (can be disabled)
- Designed specifically for in-car use

### Will this interfere with Android Auto?
No. The module monitors Android Auto but doesn't modify it. Profile switching happens in the background.

### Can this cause bootloops?
Very unlikely. The module:
- Uses standard Magisk framework
- Doesn't modify system partitions
- Can be disabled from Magisk recovery if needed

If issues occur, boot to recovery and disable/remove via Magisk.

---

## Development & Contributing

### How do I report bugs?
1. Enable `VERBOSE=1` in config
2. Reproduce the issue
3. Collect logs: `adb shell cat /data/adb/modules/caros-switcher/log.txt`
4. Open a GitHub issue with logs and details

### Can I contribute?
Absolutely! See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

### How do I build from source?
```bash
# PowerShell
.\build.ps1

# Bash
./build.sh
```

### What language is this written in?
Shell script (Bash/sh) - standard for Magisk modules.

---

## Still have questions?

1. Check [EXAMPLES.md](EXAMPLES.md) for configuration examples
2. Check [CONTRIBUTING.md](CONTRIBUTING.md) for development info
3. Open an issue on GitHub with your question
4. Include logs and device info for technical questions

**Remember:** Always include logs when asking for help!
```bash
adb shell cat /data/adb/modules/caros-switcher/log.txt
```
