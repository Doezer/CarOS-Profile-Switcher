#!/system/bin/sh
# === CarOS Profile Switcher Configuration Centralisée v0.2.3 ===
# Ce fichier contient toute la configuration par défaut du module
# Il est sourcé par post-fs-data.sh et service.sh pour garantir la cohérence

# Plusieurs noms BT possibles, séparés par | (regex), ex: "Audi|AUDI MMI|MyAudi"
DEFAULT_AUDI_BT_NAMES="Audi"

# (Optionnel) Adresse MAC si tu préfères matcher par MAC
DEFAULT_AUDI_BT_MAC=""

# Mode filaire : garder Bluetooth actif (1) ou l'éteindre (0)
DEFAULT_ALLOW_BT_IN_WIRED=1

# Gestion de la data mobile
# Hors voiture : désactiver la data mobile (1) ou la laisser active (0)
DEFAULT_DATA_OFF_OUTSIDE=1
# En voiture : garder la data active (1) pour Waze/Spotify ou l'éteindre (0)
DEFAULT_KEEP_DATA_IN_CAR=1

# Limitation CPU hors voiture (en kHz). Laisse vide pour ne pas toucher.
# Exemple : 1516800 pour ~1.5 GHz.
DEFAULT_IDLE_MAX_CPU_FREQ=""

# WIRED: limiter la charge rapide / réduire la chauffe (best effort). 1 = activer
DEFAULT_LIMIT_QUICK_CHARGE_WIRED=1

# Définir Nova Launcher comme launcher par défaut (1 = activer, 0 = désactiver)
DEFAULT_SET_NOVA_DEFAULT=1

# Gestion WiFi avancée
# WIRED: garder WiFi actif (1) ou l'éteindre (0) - utile pour VW Polo 6, etc.
DEFAULT_KEEP_WIFI_IN_WIRED=1
# IDLE: garder WiFi actif (1) ou l'éteindre (0) 
DEFAULT_KEEP_WIFI_IN_IDLE=1

# Logs verbeux
DEFAULT_VERBOSE=1

# Fonction pour générer le contenu de configuration utilisateur
generate_user_config() {
cat <<EOF
# === CarOS Profile Switcher Configuration v0.2.3 ===

# Plusieurs noms BT possibles, séparés par | (regex), ex: "Audi|AUDI MMI|MyAudi"
AUDI_BT_NAMES="$DEFAULT_AUDI_BT_NAMES"

# (Optionnel) Adresse MAC si tu préfères matcher par MAC
AUDI_BT_MAC="$DEFAULT_AUDI_BT_MAC"

# Mode filaire : garder Bluetooth actif (1) ou l'éteindre (0)
ALLOW_BT_IN_WIRED=$DEFAULT_ALLOW_BT_IN_WIRED

# Gestion de la data mobile
# Hors voiture : désactiver la data mobile (1) ou la laisser active (0)
DATA_OFF_OUTSIDE=$DEFAULT_DATA_OFF_OUTSIDE
# En voiture : garder la data active (1) pour Waze/Spotify ou l'éteindre (0)
KEEP_DATA_IN_CAR=$DEFAULT_KEEP_DATA_IN_CAR

# Limitation CPU hors voiture (en kHz). Laisse vide pour ne pas toucher.
# Exemple : 1516800 pour ~1.5 GHz.
IDLE_MAX_CPU_FREQ=$DEFAULT_IDLE_MAX_CPU_FREQ

# WIRED: limiter la charge rapide / réduire la chauffe (best effort). 1 = activer
LIMIT_QUICK_CHARGE_WIRED=$DEFAULT_LIMIT_QUICK_CHARGE_WIRED

# Définir Nova Launcher comme launcher par défaut (1 = activer, 0 = désactiver)
SET_NOVA_DEFAULT=$DEFAULT_SET_NOVA_DEFAULT

# Gestion WiFi avancée
# WIRED: garder WiFi actif (1) ou l'éteindre (0) - utile pour VW Polo 6, etc.
KEEP_WIFI_IN_WIRED=$DEFAULT_KEEP_WIFI_IN_WIRED
# IDLE: garder WiFi actif (1) ou l'éteindre (0) 
KEEP_WIFI_IN_IDLE=$DEFAULT_KEEP_WIFI_IN_IDLE

# Logs verbeux
VERBOSE=$DEFAULT_VERBOSE
EOF
}

# Fonction pour appliquer les valeurs par défaut
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
  : "${VERBOSE:=$DEFAULT_VERBOSE}"
}
