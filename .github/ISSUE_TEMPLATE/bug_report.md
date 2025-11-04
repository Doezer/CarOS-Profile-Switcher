---
name: Bug Report
about: Report a problem with CarOS Profile Switcher
title: '[BUG] '
labels: bug
assignees: ''
---

## Bug Description
<!-- A clear and concise description of what the bug is -->

## Expected Behavior
<!-- What you expected to happen -->

## Actual Behavior
<!-- What actually happened -->

## Steps to Reproduce
1. 
2. 
3. 

## Environment
- **Device**: <!-- e.g., Pixel 6, Samsung S21 -->
- **Android Version**: <!-- e.g., Android 13 -->
- **Magisk Version**: <!-- e.g., 26.1 -->
- **Module Version**: <!-- e.g., v0.2.3 -->
- **ROM**: <!-- e.g., Stock, LineageOS, etc. -->
- **Car Make/Model**: <!-- e.g., Audi A4 2021 -->

## Configuration
<!-- Paste your /sdcard/CarOS/config.env here (remove sensitive info) -->
```bash
AUDI_BT_NAMES="Your Car"
AUDI_BT_MAC=""
ALLOW_BT_IN_WIRED=1
# ... rest of config
```

## Logs
<!-- IMPORTANT: Include logs or we can't help! -->
<!-- Run: adb shell cat /data/adb/modules/caros-switcher/log.txt -->
```
Paste logs here
```

## Additional Context
<!-- Any other information that might be helpful -->

## Checklist
- [ ] I have checked [FAQ.md](../FAQ.md) for similar issues
- [ ] I have enabled verbose logging (`VERBOSE=1`)
- [ ] I have included complete logs above
- [ ] I have verified Magisk is properly installed
- [ ] I have rebooted after installing the module
