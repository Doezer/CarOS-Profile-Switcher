#!/system/bin/sh
# === CarOS Profile Switcher Centralized Configuration v0.2.4 ===
# This file contains all default configuration for the module
# It is sourced by post-fs-data.sh and service.sh to ensure consistency

# Multiple BT names possible, separated by | (regex), ex: "Audi|AUDI MMI|MyAudi"
DEFAULT_AUDI_BT_NAMES="Audi"

# (Optional) MAC address if you prefer matching by MAC
DEFAULT_AUDI_BT_MAC=""

# Wired mode: keep Bluetooth active (1) or turn it off (0)
DEFAULT_ALLOW_BT_IN_WIRED=1

# Mobile data management
# Outside car: disable mobile data (1) or leave it active (0)
DEFAULT_DATA_OFF_OUTSIDE=1
# In car: keep data active (1) for Waze/Spotify or turn it off (0)
DEFAULT_KEEP_DATA_IN_CAR=1

# CPU limitation outside car (in kHz). Leave empty to not modify.
# Example: 1516800 for ~1.5 GHz.
DEFAULT_IDLE_MAX_CPU_FREQ="1516800"

# WIRED: limit fast charging / reduce heat (best effort). 1 = enable
DEFAULT_LIMIT_QUICK_CHARGE_WIRED=1

# Set Nova Launcher as default launcher (1 = enable, 0 = disable)
DEFAULT_SET_NOVA_DEFAULT=1

# Advanced WiFi management
# WIRED: keep WiFi active (1) or turn it off (0) - useful for VW Polo 6, etc.
DEFAULT_KEEP_WIFI_IN_WIRED=0
# IDLE: keep WiFi active (1) or turn it off (0) 
DEFAULT_KEEP_WIFI_IN_IDLE=0

# IDLE: keep Bluetooth active (1) or turn it off (0). Wireless AA needs it on; wired-only carbox can use 0
DEFAULT_KEEP_BT_IN_IDLE=1

# Automatic permission management (notifications and location)
# Automatically grants necessary permissions for Android Auto, Waze, Maps, etc.
DEFAULT_AUTO_GRANT_PERMISSIONS=1

# Bluetooth audio streaming (enable device as A2DP sink to receive audio from another phone)
# When enabled, the phone becomes discoverable and can receive audio from another device
# Note: May not work if Bluetooth is used for car audio even in wired mode
DEFAULT_ENABLE_BT_AUDIO_SINK=0

# WiFi hotspot for audio streaming (alternative to Bluetooth)
# Creates a WiFi hotspot that other devices can connect to for streaming audio
# Works when WiFi is not used by the car (typically in wired mode)
DEFAULT_ENABLE_WIFI_AUDIO_HOTSPOT=0

# WiFi hotspot SSID for audio streaming
DEFAULT_WIFI_AUDIO_HOTSPOT_SSID="CarOS-Audio"

# WiFi hotspot password for audio streaming (min 8 characters).
# Empty = a random password is generated when config.env is first created
DEFAULT_WIFI_AUDIO_HOTSPOT_PASSWORD=""

# Enable the WIRELESS profile (Bluetooth connected to the car + Android Auto running).
# Set to 0 for a wired-only "carbox" setup.
DEFAULT_ENABLE_WIRELESS_PROFILE=1

# Carbox / parking mode (applies in IDLE only; all best effort)
# 1 = cut background scans, location and force Doze while the car is off
DEFAULT_PARKING_MODE=0
# Shut the phone down when idle, unplugged and battery is below this % (0 = disabled)
DEFAULT_AUTO_SHUTDOWN_PCT=0
# Remove the lock screen at boot so Android Auto can start unattended (1 = enable).
# Only works if no PIN/pattern/password is set. Security trade-off: use with care.
DEFAULT_DISABLE_LOCKSCREEN=0

# Verbose logs
DEFAULT_VERBOSE=1

# Function to generate user configuration content
generate_user_config() {
# Random hotspot password so no weak default ships
WIFI_AUDIO_HOTSPOT_PASSWORD_GEN="$(tr -dc 'A-Za-z0-9' < /dev/urandom 2>/dev/null | head -c 12)"
cat <<EOF
# === CarOS Profile Switcher Configuration v0.2.4 ===

# Multiple BT names possible, separated by | (regex), ex: "Audi|AUDI MMI|MyAudi"
AUDI_BT_NAMES="$DEFAULT_AUDI_BT_NAMES"

# (Optional) MAC address if you prefer matching by MAC
AUDI_BT_MAC="$DEFAULT_AUDI_BT_MAC"

# Wired mode: keep Bluetooth active (1) or turn it off (0)
ALLOW_BT_IN_WIRED=$DEFAULT_ALLOW_BT_IN_WIRED

# Mobile data management
# Outside car: disable mobile data (1) or leave it active (0)
DATA_OFF_OUTSIDE=$DEFAULT_DATA_OFF_OUTSIDE
# In car: keep data active (1) for Waze/Spotify or turn it off (0)
KEEP_DATA_IN_CAR=$DEFAULT_KEEP_DATA_IN_CAR

# CPU limitation outside car (in kHz). Leave empty to not modify.
# Example: 1516800 for ~1.5 GHz.
IDLE_MAX_CPU_FREQ=$DEFAULT_IDLE_MAX_CPU_FREQ

# WIRED: limit fast charging / reduce heat (best effort). 1 = enable
LIMIT_QUICK_CHARGE_WIRED=$DEFAULT_LIMIT_QUICK_CHARGE_WIRED

# Set Nova Launcher as default launcher (1 = enable, 0 = disable)
SET_NOVA_DEFAULT=$DEFAULT_SET_NOVA_DEFAULT

# Advanced WiFi management
# WIRED: keep WiFi active (1) or turn it off (0) - useful for VW Polo 6, etc.
KEEP_WIFI_IN_WIRED=$DEFAULT_KEEP_WIFI_IN_WIRED
# IDLE: keep WiFi active (1) or turn it off (0) 
KEEP_WIFI_IN_IDLE=$DEFAULT_KEEP_WIFI_IN_IDLE

# IDLE: keep Bluetooth active (1) or turn it off (0)
KEEP_BT_IN_IDLE=$DEFAULT_KEEP_BT_IN_IDLE

# Automatic permission management (notifications and location)
AUTO_GRANT_PERMISSIONS=$DEFAULT_AUTO_GRANT_PERMISSIONS

# Bluetooth audio streaming (enable device as A2DP sink to receive audio from another phone)
# Note: May not work if Bluetooth is used for car audio even in wired mode
ENABLE_BT_AUDIO_SINK=$DEFAULT_ENABLE_BT_AUDIO_SINK

# WiFi hotspot for audio streaming (alternative to Bluetooth)
ENABLE_WIFI_AUDIO_HOTSPOT=$DEFAULT_ENABLE_WIFI_AUDIO_HOTSPOT

# WiFi hotspot SSID and password
WIFI_AUDIO_HOTSPOT_SSID="$DEFAULT_WIFI_AUDIO_HOTSPOT_SSID"
WIFI_AUDIO_HOTSPOT_PASSWORD="${WIFI_AUDIO_HOTSPOT_PASSWORD_GEN:-$DEFAULT_WIFI_AUDIO_HOTSPOT_PASSWORD}"

# Enable the WIRELESS profile (0 for a wired-only carbox setup)
ENABLE_WIRELESS_PROFILE=$DEFAULT_ENABLE_WIRELESS_PROFILE

# Carbox / parking mode (IDLE only, best effort)
PARKING_MODE=$DEFAULT_PARKING_MODE
# Shut down when idle, unplugged and below this battery % (0 = disabled)
AUTO_SHUTDOWN_PCT=$DEFAULT_AUTO_SHUTDOWN_PCT
# Remove the lock screen at boot (only works without PIN/pattern/password)
DISABLE_LOCKSCREEN=$DEFAULT_DISABLE_LOCKSCREEN

# Verbose logs
VERBOSE=$DEFAULT_VERBOSE
EOF
}

# Function to apply default values
apply_defaults() {
  : "${AUDI_BT_NAMES:=$DEFAULT_AUDI_BT_NAMES}"
  : "${AUDI_BT_MAC:=$DEFAULT_AUDI_BT_MAC}"
  : "${ALLOW_BT_IN_WIRED:=$DEFAULT_ALLOW_BT_IN_WIRED}"
  : "${DATA_OFF_OUTSIDE:=$DEFAULT_DATA_OFF_OUTSIDE}"
  : "${KEEP_DATA_IN_CAR:=$DEFAULT_KEEP_DATA_IN_CAR}"
  : "${IDLE_MAX_CPU_FREQ:=$DEFAULT_IDLE_MAX_CPU_FREQ}"
  : "${LIMIT_QUICK_CHARGE_WIRED:=$DEFAULT_LIMIT_QUICK_CHARGE_WIRED}"
  : "${SET_NOVA_DEFAULT:=$DEFAULT_SET_NOVA_DEFAULT}"
  : "${KEEP_WIFI_IN_WIRED:=$DEFAULT_KEEP_WIFI_IN_WIRED}"
  : "${KEEP_WIFI_IN_IDLE:=$DEFAULT_KEEP_WIFI_IN_IDLE}"
  : "${KEEP_BT_IN_IDLE:=$DEFAULT_KEEP_BT_IN_IDLE}"
  : "${AUTO_GRANT_PERMISSIONS:=$DEFAULT_AUTO_GRANT_PERMISSIONS}"
  : "${ENABLE_BT_AUDIO_SINK:=$DEFAULT_ENABLE_BT_AUDIO_SINK}"
  : "${ENABLE_WIFI_AUDIO_HOTSPOT:=$DEFAULT_ENABLE_WIFI_AUDIO_HOTSPOT}"
  : "${WIFI_AUDIO_HOTSPOT_SSID:=$DEFAULT_WIFI_AUDIO_HOTSPOT_SSID}"
  : "${WIFI_AUDIO_HOTSPOT_PASSWORD:=$DEFAULT_WIFI_AUDIO_HOTSPOT_PASSWORD}"
  : "${ENABLE_WIRELESS_PROFILE:=$DEFAULT_ENABLE_WIRELESS_PROFILE}"
  : "${PARKING_MODE:=$DEFAULT_PARKING_MODE}"
  : "${AUTO_SHUTDOWN_PCT:=$DEFAULT_AUTO_SHUTDOWN_PCT}"
  : "${DISABLE_LOCKSCREEN:=$DEFAULT_DISABLE_LOCKSCREEN}"
  : "${VERBOSE:=$DEFAULT_VERBOSE}"

  # Numeric options are written to sysfs / compared as numbers: reject anything else
  case "$IDLE_MAX_CPU_FREQ" in *[!0-9]*) IDLE_MAX_CPU_FREQ="" ;; esac
  case "$AUTO_SHUTDOWN_PCT" in ''|*[!0-9]*) AUTO_SHUTDOWN_PCT=0 ;; esac
}

# Config keys that load_config accepts (anything else in a config file is ignored)
CONFIG_KEYS="AUDI_BT_NAMES AUDI_BT_MAC ALLOW_BT_IN_WIRED DATA_OFF_OUTSIDE KEEP_DATA_IN_CAR IDLE_MAX_CPU_FREQ LIMIT_QUICK_CHARGE_WIRED SET_NOVA_DEFAULT KEEP_WIFI_IN_WIRED KEEP_WIFI_IN_IDLE KEEP_BT_IN_IDLE AUTO_GRANT_PERMISSIONS ENABLE_BT_AUDIO_SINK ENABLE_WIFI_AUDIO_HOTSPOT WIFI_AUDIO_HOTSPOT_SSID WIFI_AUDIO_HOTSPOT_PASSWORD ENABLE_WIRELESS_PROFILE PARKING_MODE AUTO_SHUTDOWN_PCT DISABLE_LOCKSCREEN VERBOSE"

# Safely load a KEY=VALUE config file WITHOUT sourcing it: the file may live on
# /sdcard (writable by any app) while this code runs as root. Only whitelisted keys
# are read, and values are assigned as data, never evaluated as shell code.
load_config() {
  [ -f "$1" ] || return 1
  while IFS='=' read -r _key _val || [ -n "$_key" ]; do
    _key=${_key%$(printf '\r')}
    case "$_key" in ''|'#'*) continue ;; esac
    case " $CONFIG_KEYS " in *" $_key "*) ;; *) continue ;; esac
    _val=${_val%$(printf '\r')}
    case "$_val" in
      \"*\") _val=${_val#\"}; _val=${_val%\"} ;;
      \'*\') _val=${_val#\'}; _val=${_val%\'} ;;
    esac
    eval "$_key=\$_val"
  done < "$1"
  return 0
}
