#!/system/bin/sh
# === CarOS Profile Switcher Centralized Configuration v0.2.3 ===
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

# Automatic permission management (notifications and location)
# Automatically grants necessary permissions for Android Auto, Waze, Maps, etc.
DEFAULT_AUTO_GRANT_PERMISSIONS=1

# Verbose logs
DEFAULT_VERBOSE=1

# Function to generate user configuration content
generate_user_config() {
cat <<EOF
# === CarOS Profile Switcher Configuration v0.2.3 ===

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

# Automatic permission management (notifications and location)
AUTO_GRANT_PERMISSIONS=$DEFAULT_AUTO_GRANT_PERMISSIONS

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
  : "${AUTO_GRANT_PERMISSIONS:=$DEFAULT_AUTO_GRANT_PERMISSIONS}"
  : "${VERBOSE:=$DEFAULT_VERBOSE}"
}
