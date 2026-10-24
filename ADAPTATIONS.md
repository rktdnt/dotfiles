# Upstream Adaptations from `end-4/dots-hyprland`

This repository is built upon [**end-4/dots-hyprland**](https://github.com/end-4/dots-hyprland) (illogical-impulse), with specific adaptations and custom hardware control modules tailored for **Lenovo ThinkPad X395** (AMD Ryzen 5 PRO 3500U) on **Arch Linux**.

---

## Summary of Adapted Files

| File Path | Status | Upstream Source | Description of Changes / Adaptations |
| :--- | :---: | :--- | :--- |
| `.config/quickshell/ii/scripts/thinkpad-control.sh` | **NEW** | *None (Custom)* | Backend CLI controller for ThinkPad hardware (fan speeds, 3-tier power profiles, TDP limits via `ryzenadj`, battery charging limit 80%/100%). |
| `.config/quickshell/ii/modules/common/models/quickToggles/FanToggle.qml` | **NEW** | *None (Custom)* | QuickToggle model for ThinkPad fan speed control with live RPM readout and cycling modes (Auto/Full/Quiet). |
| `.config/quickshell/ii/modules/ii/sidebarRight/quickToggles/androidStyle/AndroidFanToggle.qml` | **NEW** | *None (Custom)* | Android-style UI pill delegate button for `FanToggle`. |
| `.config/quickshell/ii/modules/common/models/quickToggles/BatteryLimitToggle.qml` | **NEW** | *None (Custom)* | QuickToggle model to toggle battery charge threshold between 80% (Conservation) and 100% (Full). |
| `.config/quickshell/ii/modules/ii/sidebarRight/quickToggles/androidStyle/AndroidBatteryLimitToggle.qml` | **NEW** | *None (Custom)* | Android-style UI pill delegate button for `BatteryLimitToggle`. |
| `.config/quickshell/ii/modules/common/models/quickToggles/PowerProfilesToggle.qml` | **MODIFIED** | `dots-hyprland` | Enhanced to support 3-tier profiles (Balanced, Performance 25W TDP, Power Saver eco 8W) via `thinkpad-control.sh` on AMD Picasso where ACPI DYTC is unavailable. |
| `.config/quickshell/ii/modules/ii/sidebarRight/quickToggles/AndroidQuickPanel.qml` | **MODIFIED** | `dots-hyprland` | Added `"fan"` and `"batteryLimit"` to `availableToggleTypes` list. |
| `.config/quickshell/ii/modules/ii/sidebarRight/quickToggles/androidStyle/AndroidToggleDelegateChooser.qml` | **MODIFIED** | `dots-hyprland` | Registered delegate choices for `fan` and `batteryLimit`. |
| `.config/illogical-impulse/config.json` | **MODIFIED** | `dots-hyprland` | Configured active quick toggles layout to include `powerProfile`, `fan`, and `batteryLimit`. |
| `.config/hypr/hyprland/general.lua` | **MODIFIED** | `dots-hyprland` | Set `clickfinger_behavior = false` (restored bottom-right click), enabled `tap_to_click = true` & `tap_button_map = "lrm"`, tuned `accel_profile = "adaptive"` and `sensitivity = 0.1`. |
| `.config/hypr/monitors.lua` & `monitors.conf` | **NEW** | *None (Custom)* | Display output and scaling configuration for laptop display. |
| `etc/thinkfan.yaml` | **NEW** | *None (System)* | ThinkPad X395 fan curve mapping to hwmon sensors 1–7 (excluding unpopulated sensor 8). |
| `etc/modprobe.d/thinkpad_acpi.conf` | **NEW** | *None (System)* | Enables fan control permission (`options thinkpad_acpi fan_control=1`). |
| `etc/modprobe.d/psmouse.conf` | **NEW** | *None (System)* | Enables Elantech SMBus protocol (`options psmouse elantech_smbus=1`). |
| `install.sh` | **NEW** | *None (Custom)* | Interactive installer script for dependencies, dotfiles deployment, and ThinkPad system configuration. |

---

## Detailed Code Adaptations

### 1. Hyprland Trackpad Tuning ([`general.lua`](.config/hypr/hyprland/general.lua))

**Upstream default:**
```lua
touchpad = {
    natural_scroll = true,
    disable_while_typing = true,
    clickfinger_behavior = true,
    scroll_factor = 0.7
}
```

**Adapted configuration:**
```lua
sensitivity = 0.1,
accel_profile = "adaptive",

touchpad = {
    natural_scroll = true,
    disable_while_typing = true,
    clickfinger_behavior = false, -- Restores physical bottom-right right-click
    tap_to_click = true,          -- Enables tap to click
    tap_button_map = "lrm",       -- 2-finger tap = right click
    scroll_factor = 0.7
}
```

---

### 2. Quickshell Power Profile 3-Tier Cycling ([`PowerProfilesToggle.qml`](.config/quickshell/ii/modules/common/models/quickToggles/PowerProfilesToggle.qml))

On ThinkPad X395 (AMD Picasso APU), `power-profiles-daemon` does not expose a native `performance` mode due to lack of ACPI DYTC firmware tables. 

**Adaptation:**
The toggle was enhanced to check if `PowerProfiles.hasPerformanceProfile` is false. If false, it delegates cycling to [`thinkpad-control.sh power-cycle`](.config/quickshell/ii/scripts/thinkpad-control.sh), unlocking:
1. **Balanced:** Standard `schedutil` governor, 15W TDP.
2. **Performance:** CPU governor `performance`, 25W sustained TDP via `ryzenadj`.
3. **Power Saver:** CPU governor `powersave`, CPU Boost disabled (`boost=0`), frequency capped at 1.70 GHz, 8W TDP via `ryzenadj`.

---

### 3. Quickshell Custom Toggles Registration

* **[`AndroidQuickPanel.qml`](.config/quickshell/ii/modules/ii/sidebarRight/quickToggles/AndroidQuickPanel.qml):**
  Added `fan` and `batteryLimit` to `availableToggleTypes`.
* **[`AndroidToggleDelegateChooser.qml`](.config/quickshell/ii/modules/ii/sidebarRight/quickToggles/androidStyle/AndroidToggleDelegateChooser.qml):**
  Registered the delegate components so the buttons render cleanly in both normal and edit modes.

---

## Upstream Synchronization Guide

To pull updates from `end-4/dots-hyprland` without breaking these ThinkPad adaptations:

1. Add the upstream remote:
   ```bash
   git remote add upstream https://github.com/end-4/dots-hyprland.git
   git fetch upstream
   ```
2. When merging or rebasing, preserve:
   * The custom files in `.config/quickshell/ii/scripts/thinkpad-control.sh`
   * The custom toggles: `FanToggle.qml`, `BatteryLimitToggle.qml`, and their androidStyle delegates
   * The additions in `AndroidQuickPanel.qml` and `AndroidToggleDelegateChooser.qml`
   * The trackpad settings in `.config/hypr/hyprland/general.lua`
