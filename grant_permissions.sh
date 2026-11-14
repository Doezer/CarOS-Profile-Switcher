#!/system/bin/sh
# === CarOS Permissions Manager ===
# Ensures critical apps have the permissions and background freedom they need in the car.
# Started once per boot by service.sh (after boot_completed).

MODDIR=${0%/*}
DATADIR=/data/adb/caros
LOGFILE=$DATADIR/log.txt
CONFFILE=$DATADIR/config.env
USERCONF=/sdcard/CarOS/config.env

# Source configuration (defaults + safe loader; config files are never sourced)
[ -f "$MODDIR/caros_config.sh" ] && . "$MODDIR/caros_config.sh"
load_config "$CONFFILE"
load_config "$USERCONF"
apply_defaults 2>/dev/null || true

# Check if permission management is enabled
if [ "$AUTO_GRANT_PERMISSIONS" != "1" ]; then
  exit 0
fi

log() { echo "$(date '+%Y-%m-%d %H:%M:%S') [PERMS] $*" >> "$LOGFILE"; }

# Space-separated package lists (no bash arrays: this must run under Android's mksh)
# Android Auto, Google Maps, Waze, Nova Launcher, Google Play Services, Spotify
NOTIFICATION_APPS="com.google.android.projection.gearhead com.google.android.apps.maps com.waze com.teslacoilsw.launcher com.google.android.gms com.spotify.music"
LOCATION_APPS="com.google.android.apps.maps com.waze com.google.android.projection.gearhead"
# Never let Doze / background restrictions kill these when the phone is unattended
KEEP_ALIVE_APPS="com.google.android.projection.gearhead com.google.android.apps.maps com.waze"

PACKAGES="$(pm list packages 2>/dev/null)"
is_installed() { echo "$PACKAGES" | grep -q "^package:$1$"; }

# Grant notification access to an app
grant_notification_permission() {
  package="$1"
  is_installed "$package" || return 0
  log "Granting notification access to $package"

  # Runtime permission (Android 13+)
  pm grant "$package" android.permission.POST_NOTIFICATIONS 2>/dev/null

  # Notification listener access needs full component names (package/Class), not a bare package
  for comp in $(cmd package query-services --brief -a android.service.notification.NotificationListenerService 2>/dev/null | grep "^$package/"); do
    cmd notification allow_listener "$comp" 2>/dev/null
  done
}

# Grant location permissions to an app
grant_location_permission() {
  package="$1"
  is_installed "$package" || return 0
  log "Granting location access to $package"

  pm grant "$package" android.permission.ACCESS_FINE_LOCATION 2>/dev/null
  pm grant "$package" android.permission.ACCESS_COARSE_LOCATION 2>/dev/null
  pm grant "$package" android.permission.ACCESS_BACKGROUND_LOCATION 2>/dev/null

  appops set "$package" COARSE_LOCATION allow 2>/dev/null
  appops set "$package" FINE_LOCATION allow 2>/dev/null
}

# Exempt an app from battery optimisation / background restrictions
grant_keep_alive() {
  package="$1"
  is_installed "$package" || return 0
  log "Exempting $package from Doze / background limits"
  cmd deviceidle whitelist "+$package" >/dev/null 2>&1
  cmd appops set "$package" RUN_ANY_IN_BACKGROUND allow 2>/dev/null
  cmd appops set "$package" RUN_IN_BACKGROUND allow 2>/dev/null
}

# Grant Bluetooth permissions for audio sink functionality
grant_bluetooth_audio_permissions() {
  [ "$ENABLE_BT_AUDIO_SINK" = "1" ] || return 0
  log "Granting Bluetooth audio permissions for A2DP sink mode"

  pm grant com.android.bluetooth android.permission.BLUETOOTH_CONNECT 2>/dev/null
  pm grant com.android.bluetooth android.permission.BLUETOOTH_SCAN 2>/dev/null
  pm grant com.android.bluetooth android.permission.BLUETOOTH_ADVERTISE 2>/dev/null
  pm grant com.android.bluetooth android.permission.RECORD_AUDIO 2>/dev/null

  appops set com.android.bluetooth BLUETOOTH_SCAN allow 2>/dev/null
  appops set com.android.bluetooth BLUETOOTH_CONNECT allow 2>/dev/null
  appops set com.android.bluetooth BLUETOOTH_ADVERTISE allow 2>/dev/null
}

log "Starting permission grants..."
for app in $NOTIFICATION_APPS; do grant_notification_permission "$app"; done
for app in $LOCATION_APPS; do grant_location_permission "$app"; done
for app in $KEEP_ALIVE_APPS; do grant_keep_alive "$app"; done
grant_bluetooth_audio_permissions
log "Permission grants completed"
