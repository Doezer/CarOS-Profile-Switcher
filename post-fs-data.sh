#!/system/bin/sh
MODDIR=${0%/*}
LOGDIR=/data/adb/modules/caros-switcher
CONFDIR=/sdcard/CarOS

# Source de la configuration centralisée
. "$MODDIR/caros_config.sh"

# Attente que /sdcard soit monté (pour LineageOS)
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
  # Vérification que /sdcard est bien accessible
  if [ -w "/sdcard" ]; then
    generate_user_config > "$CONF"
    chmod 0644 "$CONF"
  else
    # Si /sdcard n'est pas accessible, on laisse service.sh s'en charger
    echo "$(date) [post-fs-data] /sdcard not writable, config will be created by service.sh" >> "$LOGDIR/log.txt"
  fi
fi

chmod 0755 "$MODDIR/service.sh"
chmod 0755 "$MODDIR/post-fs-data.sh"
chmod 0755 "$MODDIR/grant_permissions.sh"

# Grant permissions to critical apps (async to not delay boot)
"$MODDIR/grant_permissions.sh" &
