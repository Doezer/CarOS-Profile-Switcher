#!/system/bin/sh
MODDIR=${0%/*}
LOGDIR=/data/adb/modules/caros-switcher
CONFDIR=/sdcard/CarOS

# Source the centralized configuration
. "$MODDIR/caros_config.sh"

# Wait for /sdcard to be mounted (for LineageOS)
for i in $(seq 1 30); do
  if [ -d "/sdcard" ] && [ -w "/sdcard" ]; then
    break
  fi
  sleep 1
done

mkdir -p "$LOGDIR"
mkdir -p "$CONFDIR" 2>/dev/null

CONF="$CONFDIR/config.env"
if [ ! -f "$CONF" ]; then
  # Check that /sdcard is accessible
  if [ -w "/sdcard" ]; then
    generate_user_config > "$CONF"
    chmod 0644 "$CONF"
  else
    # If /sdcard is not accessible, let service.sh handle it
    echo "$(date) [post-fs-data] /sdcard not writable, config will be created by service.sh" >> "$LOGDIR/log.txt"
  fi
fi

chmod 0755 "$MODDIR/service.sh"
chmod 0755 "$MODDIR/post-fs-data.sh"
chmod 0755 "$MODDIR/grant_permissions.sh"

# Grant permissions to critical apps (async to not delay boot)
"$MODDIR/grant_permissions.sh" &
