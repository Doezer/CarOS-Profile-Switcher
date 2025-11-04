---
name: Car Compatibility Report
about: Report compatibility with a specific car model
title: '[CAR] Car Make/Model'
labels: compatibility
assignees: ''
---

## Car Information
- **Make**: <!-- e.g., Volkswagen -->
- **Model**: <!-- e.g., Golf -->
- **Year**: <!-- e.g., 2023 -->
- **Trim**: <!-- e.g., GTI -->
- **Infotainment System**: <!-- e.g., MIB3, MBUX, iDrive -->

## Compatibility Status
- [ ] ✅ Fully working
- [ ] ⚠️ Partially working (specify issues below)
- [ ] ❌ Not working

## Connection Type
- [ ] Wired Android Auto works
- [ ] Wireless Android Auto works

## Bluetooth Information
- **Bluetooth Name**: <!-- As shown in Android settings -->
- **MAC Address**: <!-- Optional, for reference -->

## Working Configuration
<!-- Share your working config.env for this car -->
```bash
AUDI_BT_NAMES="Your Car Name"
AUDI_BT_MAC=""
ALLOW_BT_IN_WIRED=1
KEEP_WIFI_IN_WIRED=1  # Needed for this car?
# ... other important settings
```

## Issues Encountered (if any)
<!-- Describe any problems or workarounds needed -->

## Tips for Other Users
<!-- Any advice for users with the same car? -->

## Environment
- **Device**: <!-- e.g., Pixel 6 -->
- **Android Version**: <!-- e.g., Android 13 -->
- **Module Version**: <!-- e.g., v0.2.3 -->

## Additional Notes
<!-- Any other relevant information -->

---
**Thank you for helping improve compatibility! 🚗**
