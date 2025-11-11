#!/system/bin/sh
# === CarOS Permissions Manager ===
# Ensures critical apps have necessary permissions for in-car use

MODDIR=${0%/*}
LOGFILE=/data/adb/modules/caros-switcher/log.txt
CONFFILE=/sdcard/CarOS/config.env

# Source configuration
[ -f "$MODDIR/caros_config.sh" ] && . "$MODDIR/caros_config.sh"
[ -f "$CONFFILE" ] && . "$CONFFILE"

# Apply defaults
apply_defaults 2>/dev/null || true

# Check if permission management is enabled
if [ "$AUTO_GRANT_PERMISSIONS" != "1" ]; then
  exit 0
fi

log() { echo "$(date '+%Y-%m-%d %H:%M:%S') [PERMS] $@" >> "$LOGFILE"; }

# List of apps that need notification permissions
NOTIFICATION_APPS=(
  "com.google.android.projection.gearhead"  # Android Auto
  "com.google.android.apps.maps"            # Google Maps
  "com.waze"                                # Waze
  "com.teslacoilsw.launcher"                # Nova Launcher
  "com.google.android.gms"                  # Google Play Services
  "com.spotify.music"                       # Spotify (common in-car app)
)

# List of apps that need location permissions
LOCATION_APPS=(
  "com.google.android.apps.maps"            # Google Maps
  "com.waze"                                # Waze
  "com.google.android.projection.gearhead"  # Android Auto
)

# Grant notification permission to an app
grant_notification_permission() {
  local package="$1"
  
  # Check if app is installed
  if ! pm list packages | grep -q "^package:${package}$"; then
    return 0  # Skip if not installed
  fi
  
  log "Granting notification access to $package"
  
  # Method 1: Direct notification listener access (Android Auto needs this)
  cmd notification allow_listener "$package" 2>/dev/null
  
  # Method 2: POST_NOTIFICATIONS permission (Android 13+)
  pm grant "$package" android.permission.POST_NOTIFICATIONS 2>/dev/null
  
  # Method 3: Settings approach
  settings put secure enabled_notification_listeners \
    "$(settings get secure enabled_notification_listeners 2>/dev/null):${package}" 2>/dev/null
}

# Grant location permissions to an app
grant_location_permission() {
  local package="$1"
  
  # Check if app is installed
  if ! pm list packages | grep -q "^package:${package}$"; then
    return 0  # Skip if not installed
  fi
  
  log "Granting location access to $package"
  
  # Grant all location-related permissions
  pm grant "$package" android.permission.ACCESS_FINE_LOCATION 2>/dev/null
  pm grant "$package" android.permission.ACCESS_COARSE_LOCATION 2>/dev/null
  pm grant "$package" android.permission.ACCESS_BACKGROUND_LOCATION 2>/dev/null
  
  # Set app ops for location (background + foreground)
  appops set "$package" COARSE_LOCATION allow 2>/dev/null
  appops set "$package" FINE_LOCATION allow 2>/dev/null
}

# Grant Bluetooth permissions for audio sink functionality
grant_bluetooth_audio_permissions() {
  # Check if Bluetooth audio sink is enabled
  if [ "$ENABLE_BT_AUDIO_SINK" != "1" ]; then
    return 0
  fi
  
  log "Granting Bluetooth audio permissions for A2DP sink mode"
  
  # Grant system-level Bluetooth permissions (Android 12+)
  pm grant com.android.bluetooth android.permission.BLUETOOTH_CONNECT 2>/dev/null
  pm grant com.android.bluetooth android.permission.BLUETOOTH_SCAN 2>/dev/null
  pm grant com.android.bluetooth android.permission.BLUETOOTH_ADVERTISE 2>/dev/null
  
  # Grant audio permissions
  pm grant com.android.bluetooth android.permission.MODIFY_AUDIO_SETTINGS 2>/dev/null
  pm grant com.android.bluetooth android.permission.RECORD_AUDIO 2>/dev/null
  
  # Set app ops for Bluetooth
  appops set com.android.bluetooth BLUETOOTH_SCAN allow 2>/dev/null
  appops set com.android.bluetooth BLUETOOTH_CONNECT allow 2>/dev/null
  appops set com.android.bluetooth BLUETOOTH_ADVERTISE allow 2>/dev/null
}

# Main execution
log "Starting permission grants..."

# Grant notification permissions
for app in "${NOTIFICATION_APPS[@]}"; do
  grant_notification_permission "$app"
done

# Grant location permissions
for app in "${LOCATION_APPS[@]}"; do
  grant_location_permission "$app"
done

# Grant Bluetooth audio permissions
grant_bluetooth_audio_permissions

log "Permission grants completed"
