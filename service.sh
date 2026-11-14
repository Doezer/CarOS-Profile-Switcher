#!/system/bin/sh
MODDIR=${0%/*}
# State lives outside the module folder so it survives module updates
DATADIR=/data/adb/caros
LOGFILE=$DATADIR/log.txt
CONFFILE=$DATADIR/config.env
# Optional user override, easy to edit from Android (only whitelisted keys are read)
USERCONF=/sdcard/CarOS/config.env
STATEFILE=$DATADIR/state.json
mkdir -p "$DATADIR" 2>/dev/null

# Source the centralized configuration (defaults + safe config loader)
. "$MODDIR/caros_config.sh"

# Rotate logs if > 1MB
rotate_log(){
    if [ -f "$LOGFILE" ] && [ "$(stat -c%s "$LOGFILE" 2>/dev/null || echo 0)" -gt 1048576 ]; then
        mv "$LOGFILE" "${LOGFILE}.old" 2>/dev/null
    fi
}
rotate_log

log() { echo "$(date '+%Y-%m-%d %H:%M:%S') $*" >> "$LOGFILE"; }
error_log() { echo "$(date '+%Y-%m-%d %H:%M:%S') [ERROR] $*" >> "$LOGFILE"; }

# Wait for the system to be fully booted: pm/cmd/settings/svc are not usable before
while [ "$(getprop sys.boot_completed)" != "1" ]; do sleep 2; done

# Create configuration if it doesn't exist
if [ ! -f "$CONFFILE" ]; then
    log "Creating config file: $CONFFILE"
    generate_user_config > "$CONFFILE"
    chmod 600 "$CONFFILE"
fi

read_config(){
    load_config "$CONFFILE"
    load_config "$USERCONF"
    apply_defaults
}

# /sdcard may be mounted slightly after boot_completed (FUSE / file-based encryption)
n=0
while [ ! -d /sdcard/Android ] && [ "$n" -lt 30 ]; do sleep 2; n=$((n+1)); done
read_config

vlog(){ [ "$VERBOSE" = "1" ] && log "[DBG]" "$@"; return 0; }

wifi_on(){
    cmd wifi set-wifi-enabled enabled >/dev/null 2>&1 || svc wifi enable >/dev/null 2>&1 || error_log "Failed to enable WiFi"
}
wifi_off(){
    cmd wifi set-wifi-enabled disabled >/dev/null 2>&1 || svc wifi disable >/dev/null 2>&1 || error_log "Failed to disable WiFi"
}

data_on(){
    log "Enabling mobile data..."
    svc data enable >/dev/null 2>&1 || settings put global mobile_data 1 >/dev/null 2>&1
    sleep 1
    DATA_STATE=$(settings get global mobile_data 2>/dev/null)
    if [ "$DATA_STATE" != "1" ]; then
        error_log "Failed to enable mobile data - state: $DATA_STATE"
        return 1
    fi
    vlog "Mobile data enabled successfully"
    return 0
}

data_off(){
    log "Disabling mobile data..."
    svc data disable >/dev/null 2>&1 || settings put global mobile_data 0 >/dev/null 2>&1
    DATA_STATE=$(settings get global mobile_data 2>/dev/null)
    if [ "$DATA_STATE" != "0" ]; then
        error_log "Failed to disable mobile data - state: $DATA_STATE"
    fi
    vlog "Mobile data disabled"
}

check_data_connection(){
    [ "$VERBOSE" != "1" ] && return 0
    
    # Check mobile data state
    DATA_ENABLED=$(settings get global mobile_data 2>/dev/null)
    vlog "Mobile data setting: $DATA_ENABLED"
    
    # Check if SIM is present and active
    SIM_STATE=$(getprop gsm.sim.state 2>/dev/null)
    vlog "SIM state: $SIM_STATE"
    
    # Check data connection state
    DATA_CONN=$(dumpsys telephony.registry 2>/dev/null | grep "mDataConnectionState" | head -1)
    vlog "Data connection: $DATA_CONN"
    
    # Check APN settings
    APN_INFO=$(dumpsys telephony.registry 2>/dev/null | grep -i "apn" | head -3)
    vlog "APN info: $APN_INFO"
    
    # Check if we have an IP address
    IP_INFO=$(ip addr show rmnet_data0 2>/dev/null || ip addr show rmnet0 2>/dev/null)
    if [ -n "$IP_INFO" ]; then
        vlog "Data interface has IP address"
    else
        vlog "WARNING: No IP address on data interface"
    fi
}

bt_on(){
    svc bluetooth enable >/dev/null 2>&1 || cmd bluetooth_manager enable >/dev/null 2>&1 || error_log "Failed to enable Bluetooth"
}
bt_off(){
    svc bluetooth disable >/dev/null 2>&1 || cmd bluetooth_manager disable >/dev/null 2>&1 || error_log "Failed to disable Bluetooth"
}

battery_saver_on(){ cmd power set-mode 1 >/dev/null 2>&1 || settings put global low_power 1 >/dev/null 2>&1 || error_log "Failed to enable battery saver"; }
battery_saver_off(){ cmd power set-mode 0 >/dev/null 2>&1 || settings put global low_power 0 >/dev/null 2>&1 || error_log "Failed to disable battery saver"; }

# Cluster-aware: each cpufreq policy (little/big cores) has its own frequency table
# (the cpuN/cpufreq entries are symlinks to these policy directories, so the glob
# below visits every policy at least once; writing twice is harmless).
set_cpu_max(){
    MAX="$1"
    [ -n "$MAX" ] || return 0
    SUCCESS=0
    for pol in /sys/devices/system/cpu/cpufreq/policy* /sys/devices/system/cpu/cpu[0-9]*/cpufreq; do
        [ -w "$pol/scaling_max_freq" ] || continue
        target="$MAX"
        read -r cmax < "$pol/cpuinfo_max_freq" 2>/dev/null
        [ -n "$cmax" ] && [ "$target" -gt "$cmax" ] && target="$cmax"
        # Highest supported frequency not above the target
        if [ -r "$pol/scaling_available_frequencies" ]; then
            read -r freqs < "$pol/scaling_available_frequencies"
            best=""
            for f in $freqs; do
                if [ "$f" -le "$target" ] && { [ -z "$best" ] || [ "$f" -gt "$best" ]; }; then best="$f"; fi
            done
            [ -n "$best" ] && target="$best"
        fi
        echo "$target" > "$pol/scaling_max_freq" 2>/dev/null && SUCCESS=1
    done
    [ "$SUCCESS" = "0" ] && error_log "Failed to set CPU max frequency to $MAX"
    return 0
}
reset_cpu_max(){
    SUCCESS=0
    for pol in /sys/devices/system/cpu/cpufreq/policy* /sys/devices/system/cpu/cpu[0-9]*/cpufreq; do
        [ -w "$pol/scaling_max_freq" ] && [ -r "$pol/cpuinfo_max_freq" ] || continue
        read -r cmax < "$pol/cpuinfo_max_freq"
        echo "$cmax" > "$pol/scaling_max_freq" 2>/dev/null && SUCCESS=1
    done
    [ "$SUCCESS" = "0" ] && vlog "No writable CPU frequency control found"
    return 0
}

# KEYCODE_SLEEP (223) never wakes the screen, unlike the POWER toggle (26)
screen_off(){ input keyevent 223 >/dev/null 2>&1; }
screen_on(){ input keyevent 224 >/dev/null 2>&1 || input keyevent 82 >/dev/null 2>&1; }

# Limit charging current only (never suspend/disable charging: the phone must
# keep charging in the car). Original values are saved to restore them later.
CHARGE_SAVE_DIR=$DATADIR/charge_orig
CHARGE_NODES="/sys/class/power_supply/usb/input_current_limit /sys/class/power_supply/battery/constant_charge_current_max"

charge_limit_on(){
    SUCCESS=0
    mkdir -p "$CHARGE_SAVE_DIR" 2>/dev/null
    for n in $CHARGE_NODES; do
        if [ -e "$n" ] && [ -w "$n" ]; then
            key="$(echo "$n" | tr '/' '_')"
            # Save the original value only once, via a temp file so an empty or
            # partial backup is never published
            if [ ! -s "$CHARGE_SAVE_DIR/$key" ]; then
                if cat "$n" > "$CHARGE_SAVE_DIR/$key.tmp" 2>/dev/null && [ -s "$CHARGE_SAVE_DIR/$key.tmp" ]; then
                    mv "$CHARGE_SAVE_DIR/$key.tmp" "$CHARGE_SAVE_DIR/$key" 2>/dev/null || {
                        error_log "Could not save charge backup for $n, skipping"
                        rm -f "$CHARGE_SAVE_DIR/$key.tmp"
                        continue
                    }
                else
                    error_log "Could not read original charge value of $n, skipping"
                    rm -f "$CHARGE_SAVE_DIR/$key.tmp"
                    continue
                fi
            fi
            echo 1000000 > "$n" 2>/dev/null && SUCCESS=1
        fi
    done
    [ "$SUCCESS" = "0" ] && vlog "No writable charge current control found"
    return $((1-SUCCESS))
}
charge_limit_off(){
    for n in $CHARGE_NODES; do
        key="$(echo "$n" | tr '/' '_')"
        if [ -s "$CHARGE_SAVE_DIR/$key" ] && [ -w "$n" ]; then
            cat "$CHARGE_SAVE_DIR/$key" > "$n" 2>/dev/null && rm -f "$CHARGE_SAVE_DIR/$key"
        fi
    done
    return 0
}

set_nova_default(){
    [ "$SET_NOVA_DEFAULT" = "1" ] || return 0
    NOVA=com.teslacoilsw.launcher

    if ! pm list packages 2>/dev/null | grep -q "^package:$NOVA$"; then
        vlog "Nova Launcher not installed, skipping default launcher setup"
        return 1
    fi

    # Android 10+: the HOME role is the supported way
    if cmd role add-role-holder --user 0 android.app.role.HOME "$NOVA" >/dev/null 2>&1; then
        vlog "Nova Launcher set as HOME role holder"
        return 0
    fi

    # Older: resolve the real HOME activity of the package instead of guessing its class
    ACT="$(cmd package resolve-activity --brief -a android.intent.action.MAIN -c android.intent.category.HOME -p "$NOVA" 2>/dev/null | tail -n 1)"
    case "$ACT" in
        "$NOVA"/*)
            if cmd package set-home-activity "$ACT" >/dev/null 2>&1 || pm set-home-activity "$ACT" >/dev/null 2>&1; then
                vlog "Nova Launcher set as default launcher ($ACT)"
                return 0
            fi
            ;;
    esac
    error_log "Could not set Nova Launcher as default launcher"
    return 1
}

# Bluetooth audio sink (EXPERIMENTAL): there is no shell command to switch the
# Bluetooth stack into A2DP sink mode. This only makes the phone discoverable; it
# works only on ROMs that already ship an A2DP sink profile.
enable_bt_audio_sink(){
    [ "$ENABLE_BT_AUDIO_SINK" = "1" ] || return 0
    bt_on
    sleep 1
    # 0 = stay discoverable while in the car
    settings put global bluetooth_discoverable_timeout 0 >/dev/null 2>&1
    log "BT Audio Sink (experimental): discoverable timeout disabled, requires ROM A2DP sink support"
}

disable_bt_audio_sink(){
    [ "$ENABLE_BT_AUDIO_SINK" = "1" ] || return 0
    settings put global bluetooth_discoverable_timeout 120 >/dev/null 2>&1
    vlog "Bluetooth audio sink mode disabled"
}

# Enable WiFi hotspot for audio streaming
enable_wifi_audio_hotspot(){
    [ "$ENABLE_WIFI_AUDIO_HOTSPOT" = "1" ] || return 0

    if [ "${#WIFI_AUDIO_HOTSPOT_PASSWORD}" -lt 8 ]; then
        error_log "WiFi hotspot password must be at least 8 characters, hotspot not started"
        return 1
    fi

    vlog "Enabling WiFi hotspot for audio streaming"
    wifi_on
    sleep 1
    cmd wifi stop-softap >/dev/null 2>&1
    sleep 1

    # Android 11+: cmd wifi start-softap <ssid> <open|wpa2|wpa3|...> <passphrase>
    if cmd wifi start-softap "$WIFI_AUDIO_HOTSPOT_SSID" wpa2 "$WIFI_AUDIO_HOTSPOT_PASSWORD" >/dev/null 2>&1; then
        log "WiFi Audio Hotspot: enabled (SSID: $WIFI_AUDIO_HOTSPOT_SSID)"
    else
        error_log "WiFi hotspot could not be started (cmd wifi start-softap failed)"
        return 1
    fi
}

disable_wifi_audio_hotspot(){
    [ "$ENABLE_WIFI_AUDIO_HOTSPOT" = "1" ] || return 0
    cmd wifi stop-softap >/dev/null 2>&1
    vlog "WiFi hotspot disabled"
}

usb_connected(){
    # Wired Android Auto puts the phone in USB accessory mode
    case "$(getprop sys.usb.state 2>/dev/null)" in
        *accessory*) return 0 ;;
    esac
    case "$(getprop sys.usb.config 2>/dev/null)" in
        *accessory*) return 0 ;;
    esac
    return 1
}

aa_process_active(){
    # Cache to avoid repeated calls
    if [ -n "$AA_CACHE" ] && [ $(($(date +%s) - AA_CACHE_TIME)) -lt 2 ]; then
        [ "$AA_CACHE" = "1" ] && return 0 || return 1
    fi

    AA_CACHE_TIME=$(date +%s)
    # Only the process counts: "dumpsys activity services" also matches idle background services
    if pidof com.google.android.projection.gearhead >/dev/null 2>&1; then
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
    
    DUMP="$(dumpsys bluetooth_manager 2>/dev/null)"
    if [ -z "$DUMP" ]; then
        vlog "Bluetooth dumpsys failed, assuming disconnected"
    else
        # "connected" as a word, not "disconnected" / "STATE_DISCONNECTED"
        CONN_RE='(^|[^A-Za-z])connected'
        # Look for a connected state close to the car's MAC or name
        if [ -n "$AUDI_BT_MAC" ] && echo "$DUMP" | grep -i -A15 "$AUDI_BT_MAC" | grep -Eiq "$CONN_RE"; then
            BT_CACHE=1
            return 0
        fi
        if [ -n "$AUDI_BT_NAMES" ] && echo "$DUMP" | grep -Ei -A15 "($ESCAPED_NAMES)" | grep -Eiq "$CONN_RE"; then
            BT_CACHE=1
            return 0
        fi
    fi

    BT_CACHE=0
    return 1
}

apply_data(){
    if [ "$KEEP_DATA_IN_CAR" = "1" ]; then
      data_on
      sleep 2  # Give data time to connect
      check_data_connection
    else
      data_off
    fi
}

# --- Carbox / parking mode helpers (best effort) ---------------------------------
parking_on(){
    [ "$PARKING_MODE" = "1" ] || return 0
    settings put global wifi_scan_always_enabled 0 >/dev/null 2>&1
    settings put global ble_scan_always_enabled 0 >/dev/null 2>&1
    cmd location set-location-enabled false >/dev/null 2>&1 || settings put secure location_mode 0 >/dev/null 2>&1
    # Force Doze (only effective while the screen is off and the phone is not charging)
    cmd deviceidle force-idle >/dev/null 2>&1
    vlog "Parking mode on"
}
parking_off(){
    [ "$PARKING_MODE" = "1" ] || return 0
    cmd deviceidle unforce >/dev/null 2>&1
    cmd location set-location-enabled true >/dev/null 2>&1 || settings put secure location_mode 3 >/dev/null 2>&1
    vlog "Parking mode off"
}

# Shut the phone down when idle, unplugged and low, to protect an unattended battery
check_auto_shutdown(){
    [ "$AUTO_SHUTDOWN_PCT" -gt 0 ] || return 0
    BAT=/sys/class/power_supply/battery
    [ -r "$BAT/capacity" ] || return 0
    read -r LEVEL < "$BAT/capacity"
    read -r CHG < "$BAT/status"
    case "$CHG" in
        Charging|Full) return 0 ;;
    esac
    case "$LEVEL" in ''|*[!0-9]*) return 0 ;; esac
    if [ "$LEVEL" -lt "$AUTO_SHUTDOWN_PCT" ]; then
        log "Battery at ${LEVEL}% (< ${AUTO_SHUTDOWN_PCT}%) and not charging: shutting down"
        reboot -p >/dev/null 2>&1 || svc power shutdown >/dev/null 2>&1
    fi
}

disable_lockscreen(){
    [ "$DISABLE_LOCKSCREEN" = "1" ] || return 0
    if locksettings set-disabled true >/dev/null 2>&1; then
        log "Lock screen disabled"
    else
        error_log "Could not disable the lock screen (a PIN/pattern/password is probably set)"
    fi
}

# --- Profiles ---------------------------------------------------------------------
apply_wired_profile(){
    apply_data
    if [ "$ALLOW_BT_IN_WIRED" = "1" ]; then bt_on; else bt_off; fi
    if [ "$KEEP_WIFI_IN_WIRED" = "1" ]; then wifi_on; else wifi_off; fi
    battery_saver_off
    parking_off
    reset_cpu_max
    if [ "$LIMIT_QUICK_CHARGE_WIRED" = "1" ]; then charge_limit_on; else charge_limit_off; fi
    set_nova_default
    # Enable audio streaming (Bluetooth or WiFi hotspot based on config)
    enable_bt_audio_sink
    enable_wifi_audio_hotspot
}

apply_wireless_profile(){
    bt_on
    wifi_on
    apply_data
    battery_saver_off
    parking_off
    reset_cpu_max
    charge_limit_off
    set_nova_default
    # BT audio sink is not enabled in wireless mode: Bluetooth (and WiFi) are used by the car link.
}

apply_idle_profile(){
    if [ "$KEEP_WIFI_IN_IDLE" = "1" ]; then wifi_on; else wifi_off; fi
    if [ "$DATA_OFF_OUTSIDE" = "1" ]; then
      data_off
    else
      data_on
    fi
    # WIRELESS detection needs Bluetooth, so it stays on unless KEEP_BT_IN_IDLE=0
    if [ "$KEEP_BT_IN_IDLE" = "1" ]; then bt_on; else bt_off; fi
    battery_saver_on
    set_cpu_max "$IDLE_MAX_CPU_FREQ"
    charge_limit_off
    disable_bt_audio_sink
    disable_wifi_audio_hotspot
    parking_on
}

apply_profile(){
    case "$1" in
        WIRED)    apply_wired_profile ;;
        WIRELESS) apply_wireless_profile ;;
        IDLE)     apply_idle_profile ;;
    esac
}

STATE=""
LOOP_COUNT=0
AA_CACHE=""
AA_CACHE_TIME=0
BT_CACHE=""
BT_CACHE_TIME=0
LAST_APPLY=0
LAST_SHUTDOWN_CHECK=0
REAPPLY_EVERY=300   # seconds: re-apply the current profile in case something changed radios behind our back
log "CarOS Profile Switcher service v0.2.4 started"

if [ "$ENABLE_WIRELESS_PROFILE" = "1" ] && [ "$KEEP_WIFI_IN_IDLE" != "1" ]; then
    log "[WARN] Wireless Android Auto needs WiFi before the phone connects: set KEEP_WIFI_IN_IDLE=1, or ENABLE_WIRELESS_PROFILE=0 for a wired-only setup"
fi

disable_lockscreen

# Grant permissions once per boot (async)
"$MODDIR/grant_permissions.sh" &

while true; do
    LOOP_COUNT=$((LOOP_COUNT + 1))
    NOW=$(date +%s)

    # Periodic log to prove the service is working; also re-read the config so edits apply live
    if [ $((LOOP_COUNT % 100)) -eq 0 ]; then
        log "Service alive, loop #$LOOP_COUNT, state $STATE"
        rotate_log
        read_config
    fi

    WIRED=0
    WIRELESS=0

    if usb_connected && aa_process_active; then
        WIRED=1
        vlog "Detected WIRED mode"
    elif [ "$ENABLE_WIRELESS_PROFILE" = "1" ] && bt_connected_to_audi && aa_process_active; then
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
        apply_profile "$NEWSTATE"
        # Screen off only on a real transition (not on the periodic re-apply)
        [ "$NEWSTATE" = "IDLE" ] || screen_off
        log "Applied $NEWSTATE profile"
        STATE="$NEWSTATE"
        LAST_APPLY=$(date +%s)
        echo "{\"state\":\"$STATE\",\"timestamp\":\"$(date)\"}" > "$STATEFILE" 2>/dev/null
    elif [ $((NOW - LAST_APPLY)) -ge "$REAPPLY_EVERY" ]; then
        vlog "Re-applying $STATE profile"
        apply_profile "$STATE"
        LAST_APPLY=$(date +%s)
    fi

    if [ "$STATE" = "IDLE" ]; then
        # Poll less often (and run fewer dumpsys) while the car is off
        if [ $((NOW - LAST_SHUTDOWN_CHECK)) -ge 60 ]; then
            check_auto_shutdown
            LAST_SHUTDOWN_CHECK=$NOW
        fi
        sleep 10
    else
        sleep 3
    fi
done
