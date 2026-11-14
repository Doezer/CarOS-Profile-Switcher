#!/system/bin/sh
# post-fs-data runs early and blocks boot: keep it minimal.
# /sdcard, pm, settings and cmd are NOT available yet. Everything else
# (config creation, permissions, profiles) is done by service.sh after boot.
MODDIR=${0%/*}

chmod 0755 "$MODDIR/service.sh" "$MODDIR/post-fs-data.sh" "$MODDIR/grant_permissions.sh"
