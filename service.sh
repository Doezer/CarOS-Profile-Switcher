#!/system/bin/sh
MODDIR=${0%/*}
LOGFILE=/data/adb/modules/caros-switcher/log.txt
CONFFILE=/sdcard/CarOS/config.env
STATEFILE=/data/adb/modules/caros-switcher/state.json

# Source the centralized configuration
. "$MODDIR/caros_config.sh"

# Rotate logs if > 1MB
if [ -f "$LOGFILE" ] && [ "$(stat -c%s "$LOGFILE" 2>/dev/null || echo 0)" -gt 1048576 ]; then
  mv "$LOGFILE" "${LOGFILE}.old" 2>/dev/null
fi

log() { echo "$(date '+%Y-%m-%d %H:%M:%S') $@" >> "$LOGFILE"; }
error_log() { echo "$(date '+%Y-%m-%d %H:%M:%S') [ERROR] $@" >> "$LOGFILE"; }

# Create configuration if it doesn't exist
if [ ! -f "$CONFFILE" ]; then
  mkdir -p "$(dirname "$CONFFILE")"
  log "Creating config file: $CONFFILE"
  generate_user_config > "$CONFFILE"
  chmod 644 "$CONFFILE"
  log "Config file created successfully"
fi

[ -f "$CONFFILE" ] && . "$CONFFILE"

# Apply default values
apply_defaults

vlog(){ [ "$VERBOSE" = "1" ] && log "[DBG]" "$@"; }

wifi_on(){ 
  cmd wifi set-wifi-enabled enabled 2>/dev/null || svc wifi enable 2>/dev/null || {
    settings put global wifi_on 1 2>/dev/null || error_log "Failed to enable WiFi"
  }
}
wifi_off(){ 
  cmd wifi set-wifi-enabled disabled 2>/dev/null || svc wifi disable 2>/dev/null || {
    settings put global wifi_on 0 2>/dev/null || error_log "Failed to disable WiFi"
  }
}
data_on(){ 
  settings put global mobile_data 1 2>/dev/null || svc data enable 2>/dev/null || error_log "Failed to enable mobile data"
}
data_off(){ 
  settings put global mobile_data 0 2>/dev/null || svc data disable 2>/dev/null || error_log "Failed to disable mobile data"
}
bt_on(){ 
  cmd bluetooth enable >/dev/null 2>&1 || settings put global bluetooth_on 1 >/dev/null 2>&1 || {
    service call bluetooth_manager 6 >/dev/null 2>&1 || error_log "Failed to enable Bluetooth"
  }
}
bt_off(){ 
  cmd bluetooth disable >/dev/null 2>&1 || settings put global bluetooth_on 0 >/dev/null 2>&1 || {
    service call bluetooth_manager 8 >/dev/null 2>&1 || error_log "Failed to disable Bluetooth"
  }
}

battery_saver_on(){ settings put global low_power 1 || error_log "Failed to enable battery saver"; }
battery_saver_off(){ settings put global low_power 0 || error_log "Failed to disable battery saver"; }

set_cpu_max(){
  MAX="$1"
  if [ -n "$MAX" ]; then
    SUCCESS=0
    for cpu in /sys/devices/system/cpu/cpu[0-9]*; do
      if [ -e "$cpu/cpufreq/scaling_max_freq" ] && [ -w "$cpu/cpufreq/scaling_max_freq" ]; then
        echo "$MAX" > "$cpu/cpufreq/scaling_max_freq" 2>/dev/null && SUCCESS=1
      fi
    done
    [ "$SUCCESS" = "0" ] && error_log "Failed to set CPU max frequency to $MAX"
  fi
}
reset_cpu_max(){
  SUCCESS=0
  for cpu in /sys/devices/system/cpu/cpu[0-9]*; do
    if [ -e "$cpu/cpufreq/scaling_max_freq" ] && [ -e "$cpu/cpufreq/cpuinfo_max_freq" ] && [ -w "$cpu/cpufreq/scaling_max_freq" ]; then
      cat "$cpu/cpufreq/cpuinfo_max_freq" > "$cpu/cpufreq/scaling_max_freq" 2>/dev/null && SUCCESS=1
    fi
  done
  [ "$SUCCESS" = "0" ] && error_log "Failed to reset CPU max frequency"
}

screen_off(){ input keyevent 26 >/dev/null 2>&1; }
screen_on(){ input keyevent 224 >/dev/null 2>&1 || input keyevent 82 >/dev/null 2>&1; }

charge_limit_on(){
  SUCCESS=0
  for n in \
    /sys/class/power_supply/battery/charging_enabled \
    /sys/class/power_supply/battery/charge_enabled \
    /sys/class/power_supply/battery/charge_disable \
    /sys/class/power_supply/battery/input_suspend \
    /sys/class/power_supply/usb/input_current_limit \
    /sys/class/power_supply/battery/constant_charge_current_max \
    ; do
    if [ -e "$n" ] && [ -w "$n" ]; then
      case "$n" in
        */input_current_limit|*/constant_charge_current_max)
          echo 500000 > "$n" 2>/dev/null && SUCCESS=1 ;;
        *charging_enabled|*charge_enabled)
          echo 0 > "$n" 2>/dev/null && SUCCESS=1 ;;
        *charge_disable|*input_suspend)
          echo 1 > "$n" 2>/dev/null && SUCCESS=1 ;;
      esac
    fi
  done
  [ "$SUCCESS" = "0" ] && vlog "No writable charge control found"
  return $((1-SUCCESS))
}
charge_limit_off(){
  SUCCESS=0
  for n in \
    /sys/class/power_supply/battery/charging_enabled \
    /sys/class/power_supply/battery/charge_enabled \
    /sys/class/power_supply/battery/charge_disable \
    /sys/class/power_supply/battery/input_suspend \
    /sys/class/power_supply/usb/input_current_limit \
    /sys/class/power_supply/battery/constant_charge_current_max \
    ; do
    if [ -e "$n" ] && [ -w "$n" ]; then
      case "$n" in
        */input_current_limit|*/constant_charge_current_max)
          echo 3000000 > "$n" 2>/dev/null && SUCCESS=1 ;;
        *charging_enabled|*charge_enabled)
          echo 1 > "$n" 2>/dev/null && SUCCESS=1 ;;
        *charge_disable|*input_suspend)
          echo 0 > "$n" 2>/dev/null && SUCCESS=1 ;;
      esac
    fi
  done
  [ "$SUCCESS" = "0" ] && vlog "No writable charge control found"
  return 0
}

set_nova_default(){
  [ "$SET_NOVA_DEFAULT" = "1" ] || return 0
  
  # Vérifier si Nova Launcher est installé
  if ! pm list packages | grep -q "com.teslacoilsw.launcher"; then
    vlog "Nova Launcher not installed, skipping default launcher setup"
    return 1
  fi
  
  # Définir Nova Launcher comme launcher par défaut
  if cmd package set-home-activity com.teslacoilsw.launcher/com.android.launcher3.Launcher >/dev/null 2>&1; then
    vlog "Nova Launcher set as default launcher"
    return 0
  elif pm set-home-activity com.teslacoilsw.launcher/com.android.launcher3.Launcher >/dev/null 2>&1; then
    vlog "Nova Launcher set as default launcher (fallback method)"
    return 0
  else
    # Méthode alternative avec settings
    settings put secure default_input_method com.teslacoilsw.launcher >/dev/null 2>&1
    vlog "Nova Launcher setup attempted via settings"
    return 0
  fi
}

usb_connected(){
  if [ -f /sys/class/power_supply/usb/online ] && [ "$(cat /sys/class/power_supply/usb/online 2>/dev/null)" = "1" ]; then
    return 0
  fi
  dumpsys usb 2>/dev/null | grep -q "mConnected=true" && return 0
  return 1
}

aa_process_active(){
  # Cache to avoid repeated calls
  if [ -n "$AA_CACHE" ] && [ $(($(date +%s) - AA_CACHE_TIME)) -lt 2 ]; then
    [ "$AA_CACHE" = "1" ] && return 0 || return 1
  fi
  
  AA_CACHE_TIME=$(date +%s)
  if pidof com.google.android.projection.gearhead >/dev/null 2>&1; then
    AA_CACHE=1
    return 0
  fi
  
  if dumpsys activity services 2>/dev/null | grep -qi com.google.android.projection.gearhead; then
    AA_CACHE=1
    return 0
  fi
  
  AA_CACHE=0
  return 1
}

bt_connected_to_audi(){
  # Quick check with cache
  if [ -n "$BT_CACHE" ] && [ $(($(date +%s) - BT_CACHE_TIME)) -lt 5 ]; then
    [ "$BT_CACHE" = "1" ] && return 0 || return 1
  fi
  
  BT_CACHE_TIME=$(date +%s)
  
  # Escape special characters in AUDI_BT_NAMES
  ESCAPED_NAMES="$(echo "$AUDI_BT_NAMES" | sed 's/[].[^$\\/*]/\\&/g')"
  
  # Quick attempt with dumpsys
  if DUMP="$(dumpsys bluetooth_manager 2>/dev/null | head -100)"; then
    # Check by MAC if specified
    if [ -n "$AUDI_BT_MAC" ]; then
      if echo "$DUMP" | grep -i "$AUDI_BT_MAC" | grep -qi "Connected.*true\|State.*Connected"; then
        BT_CACHE=1
        return 0
      fi
    fi
    
    # Check by name
    if echo "$DUMP" | grep -Eiq "Name:.*($ESCAPED_NAMES)" && echo "$DUMP" | grep -qi "Connected.*true\|State.*Connected"; then
      BT_CACHE=1
      return 0
    fi
    
    # Fallback: broader search
    if echo "$DUMP" | grep -Eiq "($ESCAPED_NAMES)" && echo "$DUMP" | grep -qi "Connected"; then
      BT_CACHE=1
      return 0
    fi
  else
    vlog "Bluetooth dumpsys failed, assuming disconnected"
  fi
  
  BT_CACHE=0
  return 1
}

apply_wired_profile(){
  if [ "$KEEP_DATA_IN_CAR" = "1" ]; then data_on; else data_off; fi
  if [ "$ALLOW_BT_IN_WIRED" = "1" ]; then bt_on; else bt_off; fi
  if [ "$KEEP_WIFI_IN_WIRED" = "1" ]; then wifi_on; else wifi_off; fi
  battery_saver_off
  reset_cpu_max
  [ "$LIMIT_QUICK_CHARGE_WIRED" = "1" ] && charge_limit_on
  set_nova_default
  screen_off
}

apply_wireless_profile(){
  bt_on
  wifi_on
  if [ "$KEEP_DATA_IN_CAR" = "1" ]; then data_on; else data_off; fi
  battery_saver_off
  reset_cpu_max
  charge_limit_off
  set_nova_default
  screen_off
}

apply_idle_profile(){
  if [ "$KEEP_WIFI_IN_IDLE" = "1" ]; then wifi_on; else wifi_off; fi
  if [ "$DATA_OFF_OUTSIDE" = "1" ]; then data_off; else data_on; fi
  battery_saver_on
  set_cpu_max "$IDLE_MAX_CPU_FREQ"
  charge_limit_off
}

STATE=""
LOOP_COUNT=0
AA_CACHE=""
AA_CACHE_TIME=0
BT_CACHE=""
BT_CACHE_TIME=0
log "CarOS Profile Switcher service v0.2.3 started"

# Grant permissions on service start (async)
"$MODDIR/grant_permissions.sh" &

while true; do
  LOOP_COUNT=$((LOOP_COUNT + 1))
  
  # Periodic log to prove the service is working
  [ $((LOOP_COUNT % 100)) -eq 0 ] && log "Service alive, loop #$LOOP_COUNT"
  
  # Re-grant permissions periodically (every ~30 minutes = 600 loops)
  if [ $((LOOP_COUNT % 600)) -eq 0 ]; then
    "$MODDIR/grant_permissions.sh" &
  fi
  
  WIRED=0
  WIRELESS=0

  # Check with error handling
  if usb_connected && aa_process_active; then
    WIRED=1
    vlog "Detected WIRED mode"
  elif bt_connected_to_audi && aa_process_active; then
    WIRELESS=1
    vlog "Detected WIRELESS mode"
  fi

  NEWSTATE="IDLE"
  if [ "$WIRED" = "1" ]; then
    NEWSTATE="WIRED"
  elif [ "$WIRELESS" = "1" ]; then
    NEWSTATE="WIRELESS"
  fi

  if [ "$NEWSTATE" != "$STATE" ]; then
    log "State change: $STATE -> $NEWSTATE"
    case "$NEWSTATE" in
      WIRED) 
        apply_wired_profile
        log "Applied WIRED profile"
        ;;
      WIRELESS) 
        apply_wireless_profile
        log "Applied WIRELESS profile"
        ;;
      IDLE) 
        apply_idle_profile
        log "Applied IDLE profile"
        ;;
    esac
    STATE="$NEWSTATE"
    # Save state
    echo "{\"state\":\"$STATE\",\"timestamp\":\"$(date)\"}" > "$STATEFILE" 2>/dev/null
  fi

  sleep 3
done
