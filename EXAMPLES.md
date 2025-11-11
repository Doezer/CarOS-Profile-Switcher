# Configuration Examples

Real-world configuration examples for different car models and use cases.

## 🚗 Car-Specific Configurations

### Audi (Default)
```bash
# Works with most Audi models with MMI
AUDI_BT_NAMES="Audi|AUDI MMI|MMI"
AUDI_BT_MAC=""
ALLOW_BT_IN_WIRED=1
DATA_OFF_OUTSIDE=1
KEEP_DATA_IN_CAR=1
IDLE_MAX_CPU_FREQ=""
LIMIT_QUICK_CHARGE_WIRED=1
SET_NOVA_DEFAULT=1
KEEP_WIFI_IN_WIRED=0
KEEP_WIFI_IN_IDLE=1
VERBOSE=1
```

### Volkswagen (VW Polo 6, Golf, etc.)
```bash
# VW systems often need WiFi for wireless Android Auto
AUDI_BT_NAMES="VW|Volkswagen|Polo|Golf"
AUDI_BT_MAC=""
ALLOW_BT_IN_WIRED=1
DATA_OFF_OUTSIDE=1
KEEP_DATA_IN_CAR=1
IDLE_MAX_CPU_FREQ=""
LIMIT_QUICK_CHARGE_WIRED=1
SET_NOVA_DEFAULT=1
KEEP_WIFI_IN_WIRED=1      # Important for VW!
KEEP_WIFI_IN_IDLE=1
VERBOSE=1
```

### BMW
```bash
# BMW iDrive systems
AUDI_BT_NAMES="BMW|iDrive|My BMW"
AUDI_BT_MAC=""
ALLOW_BT_IN_WIRED=1
DATA_OFF_OUTSIDE=1
KEEP_DATA_IN_CAR=1
IDLE_MAX_CPU_FREQ=""
LIMIT_QUICK_CHARGE_WIRED=1
SET_NOVA_DEFAULT=1
KEEP_WIFI_IN_WIRED=0
KEEP_WIFI_IN_IDLE=1
VERBOSE=1
```

### Mercedes-Benz
```bash
# Mercedes MBUX / COMAND systems
AUDI_BT_NAMES="Mercedes|MB|MBUX|COMAND"
AUDI_BT_MAC=""
ALLOW_BT_IN_WIRED=1
DATA_OFF_OUTSIDE=1
KEEP_DATA_IN_CAR=1
IDLE_MAX_CPU_FREQ=""
LIMIT_QUICK_CHARGE_WIRED=1
SET_NOVA_DEFAULT=1
KEEP_WIFI_IN_WIRED=0
KEEP_WIFI_IN_IDLE=1
VERBOSE=1
```

### Generic / Aftermarket Head Units
```bash
# Works with most generic Android Auto head units
AUDI_BT_NAMES="CarPlay|Android|Car Audio|Head Unit"
AUDI_BT_MAC=""
ALLOW_BT_IN_WIRED=1
DATA_OFF_OUTSIDE=1
KEEP_DATA_IN_CAR=1
IDLE_MAX_CPU_FREQ=""
LIMIT_QUICK_CHARGE_WIRED=1
SET_NOVA_DEFAULT=1
KEEP_WIFI_IN_WIRED=0
KEEP_WIFI_IN_IDLE=1
VERBOSE=1
```

### Using MAC Address (Most Reliable)
```bash
# Use this if Bluetooth name matching is unreliable
# Find your car's MAC: Settings > Bluetooth > Paired devices > Car > Details
AUDI_BT_NAMES="Audi"
AUDI_BT_MAC="AA:BB:CC:DD:EE:FF"  # Replace with your car's MAC
ALLOW_BT_IN_WIRED=1
DATA_OFF_OUTSIDE=1
KEEP_DATA_IN_CAR=1
IDLE_MAX_CPU_FREQ=""
LIMIT_QUICK_CHARGE_WIRED=1
SET_NOVA_DEFAULT=1
KEEP_WIFI_IN_WIRED=0
KEEP_WIFI_IN_IDLE=1
VERBOSE=1
```

## 🎯 Use Case Configurations

### Maximum Battery Saving
```bash
# Aggressive battery saving when not in car
AUDI_BT_NAMES="Your Car"
AUDI_BT_MAC=""
ALLOW_BT_IN_WIRED=0           # Turn off BT in wired mode
DATA_OFF_OUTSIDE=1            # Disable data when idle
KEEP_DATA_IN_CAR=0            # Disable data even in car
IDLE_MAX_CPU_FREQ="1516800"   # Throttle CPU to ~1.5GHz
LIMIT_QUICK_CHARGE_WIRED=1    # Limit charging
SET_NOVA_DEFAULT=1
KEEP_WIFI_IN_WIRED=0          # Turn off WiFi
KEEP_WIFI_IN_IDLE=1
AUTO_GRANT_PERMISSIONS=1
ENABLE_BT_AUDIO_SINK=0         # Disable to save battery
VERBOSE=0                      # Reduce logging overhead
```

### Maximum Performance (Data Heavy Usage)
```bash
# Keep everything on for Waze, Spotify, etc.
AUDI_BT_NAMES="Your Car"
AUDI_BT_MAC=""
ALLOW_BT_IN_WIRED=1           # Keep BT on
DATA_OFF_OUTSIDE=0            # Keep data always on
KEEP_DATA_IN_CAR=1            # Data on in car
IDLE_MAX_CPU_FREQ=""          # No CPU throttling
LIMIT_QUICK_CHARGE_WIRED=0    # Allow fast charging
SET_NOVA_DEFAULT=1
KEEP_WIFI_IN_WIRED=1          # Keep WiFi on
KEEP_WIFI_IN_IDLE=1           # Keep WiFi on
AUTO_GRANT_PERMISSIONS=1
ENABLE_BT_AUDIO_SINK=0
VERBOSE=1
```

### Audio Streaming via Bluetooth
```bash
# Enable receiving audio from another phone via Bluetooth
# Note: May not work if Bluetooth is used for car audio even in wired mode
AUDI_BT_NAMES="Your Car"
AUDI_BT_MAC=""
ALLOW_BT_IN_WIRED=1           # Must keep BT on for audio streaming
DATA_OFF_OUTSIDE=1
KEEP_DATA_IN_CAR=1
IDLE_MAX_CPU_FREQ=""
LIMIT_QUICK_CHARGE_WIRED=1
SET_NOVA_DEFAULT=1
KEEP_WIFI_IN_WIRED=0
KEEP_WIFI_IN_IDLE=1
AUTO_GRANT_PERMISSIONS=1
ENABLE_BT_AUDIO_SINK=1        # Enable Bluetooth audio sink mode
ENABLE_WIFI_AUDIO_HOTSPOT=0
VERBOSE=1
```

### Audio Streaming via WiFi Hotspot (Recommended)
```bash
# Enable WiFi hotspot for audio streaming (works even if BT used for car audio)
AUDI_BT_NAMES="Your Car"
AUDI_BT_MAC=""
ALLOW_BT_IN_WIRED=1
DATA_OFF_OUTSIDE=1
KEEP_DATA_IN_CAR=1
IDLE_MAX_CPU_FREQ=""
LIMIT_QUICK_CHARGE_WIRED=1
SET_NOVA_DEFAULT=1
KEEP_WIFI_IN_WIRED=1          # WiFi must be on for hotspot
KEEP_WIFI_IN_IDLE=1
AUTO_GRANT_PERMISSIONS=1
ENABLE_BT_AUDIO_SINK=0
ENABLE_WIFI_AUDIO_HOTSPOT=1  # Enable WiFi hotspot for audio streaming
WIFI_AUDIO_HOTSPOT_SSID="CarOS-Audio"
WIFI_AUDIO_HOTSPOT_PASSWORD="caros123"
VERBOSE=1
```

### Minimal Configuration (Wireless Only)
```bash
# Only use wireless Android Auto, no wired
AUDI_BT_NAMES="Your Car"
AUDI_BT_MAC=""
ALLOW_BT_IN_WIRED=1
DATA_OFF_OUTSIDE=1
KEEP_DATA_IN_CAR=1
IDLE_MAX_CPU_FREQ=""
LIMIT_QUICK_CHARGE_WIRED=0    # Disable since not using wired
SET_NOVA_DEFAULT=0            # Don't change launcher
KEEP_WIFI_IN_WIRED=1          # Keep WiFi for wireless AA
KEEP_WIFI_IN_IDLE=1
VERBOSE=1
```

### Multiple Cars
```bash
# Use regex to match multiple cars
AUDI_BT_NAMES="Audi|BMW|Rental Car|Work Van"
AUDI_BT_MAC=""
ALLOW_BT_IN_WIRED=1
DATA_OFF_OUTSIDE=1
KEEP_DATA_IN_CAR=1
IDLE_MAX_CPU_FREQ=""
LIMIT_QUICK_CHARGE_WIRED=1
SET_NOVA_DEFAULT=1
KEEP_WIFI_IN_WIRED=1
KEEP_WIFI_IN_IDLE=1
VERBOSE=1
```

### Debugging Configuration
```bash
# Use this when troubleshooting issues
AUDI_BT_NAMES="Your Car"
AUDI_BT_MAC=""
ALLOW_BT_IN_WIRED=1
DATA_OFF_OUTSIDE=0            # Keep data on for debugging
KEEP_DATA_IN_CAR=1
IDLE_MAX_CPU_FREQ=""
LIMIT_QUICK_CHARGE_WIRED=0    # Don't limit while debugging
SET_NOVA_DEFAULT=1
KEEP_WIFI_IN_WIRED=1
KEEP_WIFI_IN_IDLE=1
VERBOSE=1                      # Full logging
```

## 🔍 How to Find Your Car's Bluetooth Name

### Method 1: Android Settings
1. Go to **Settings** > **Bluetooth**
2. Look at **Paired devices**
3. Your car's name is shown there

### Method 2: Check Logs
1. Enable verbose logging: `VERBOSE=1`
2. Connect to your car
3. View logs: `adb shell cat /data/adb/modules/caros-switcher/log.txt`
4. Look for lines mentioning Bluetooth device names

### Method 3: Dumpsys (Advanced)
```bash
adb shell dumpsys bluetooth_manager | grep -i "name"
```

## 🔍 How to Find Your Car's MAC Address

### Method 1: Android Settings (Most Devices)
1. Go to **Settings** > **Bluetooth**
2. Tap on your car's name
3. Look for **Device details** or **Info**
4. MAC address shown as **AA:BB:CC:DD:EE:FF**

### Method 2: Developer Options
1. Enable **Developer Options**
2. Go to **Settings** > **System** > **Developer Options**
3. Enable **Bluetooth HCI snoop log**
4. Connect to car
5. Use Bluetooth sniffer tools to view MAC

### Method 3: ADB Command
```bash
adb shell dumpsys bluetooth_manager | grep -A 10 "Bonded devices"
```

## 💡 Tips

### Regex Pattern Matching
The `AUDI_BT_NAMES` field supports regex patterns:
- `Audi` - Matches exactly "Audi"
- `Audi|VW` - Matches "Audi" OR "VW"
- `.*Audi.*` - Matches anything containing "Audi"
- `^Audi$` - Matches only exactly "Audi" (strict)

### Special Characters
If your car name has special characters, escape them:
```bash
# Car name: "John's Audi"
AUDI_BT_NAMES="John's Audi"

# Car name: "Car (2024)"
AUDI_BT_NAMES="Car \\(2024\\)"
```

### Testing Your Configuration
After editing `/sdcard/CarOS/config.env`:
1. Don't need to reboot (config reloads automatically)
2. Connect to your car
3. Check logs: `adb shell tail -f /data/adb/modules/caros-switcher/log.txt`
4. Should see "State change: IDLE -> WIRELESS" or "-> WIRED"

### Common Pitfalls
- ❌ Name has spaces: Use exact name including spaces
- ❌ Name case-sensitive: Match exactly as shown in Bluetooth settings
- ❌ Using `|` in MAC address: Don't use regex in MAC field
- ✅ When in doubt: Use MAC address matching instead

## 🆘 Need Help?

If these examples don't work for your car:
1. Enable `VERBOSE=1`
2. Connect to your car
3. Collect logs
4. Open an issue with:
   - Car make/model/year
   - Android version
   - Relevant log excerpts
   - Bluetooth name from settings
