#!/usr/bin/env bash
set -e

FAN_FILE="/proc/acpi/ibm/fan"

get_fan_speed() {
    if [ -f "$FAN_FILE" ]; then
        awk '/speed:/ {print $2}' "$FAN_FILE"
    else
        echo "0"
    fi
}

get_fan_level() {
    if [ -f "$FAN_FILE" ]; then
        awk '/level:/ {print $2}' "$FAN_FILE"
    else
        echo "unknown"
    fi
}

fan_status() {
    local speed level mode
    speed=$(get_fan_speed)
    level=$(get_fan_level)
    
    if systemctl is-active --quiet thinkfan; then
        mode="Auto"
    else
        case "$level" in
            7|disengaged|full-speed)
                mode="Full"
                ;;
            0|1)
                mode="Quiet"
                ;;
            auto)
                mode="BIOS"
                ;;
            *)
                mode="Manual"
                ;;
        esac
    fi
    echo "${mode}|${speed}|${level}"
}

fan_set() {
    local target="$1"
    case "$target" in
        auto)
            systemctl start thinkfan
            ;;
        full)
            systemctl stop thinkfan 2>/dev/null || true
            echo "level 7" > "$FAN_FILE"
            ;;
        quiet)
            systemctl stop thinkfan 2>/dev/null || true
            echo "level 1" > "$FAN_FILE"
            ;;
        bios)
            systemctl stop thinkfan 2>/dev/null || true
            echo "level auto" > "$FAN_FILE"
            ;;
        *)
            echo "Unknown fan target: $target" >&2
            exit 1
            ;;
    esac
}

fan_cycle() {
    local current_mode
    current_mode=$(fan_status | cut -d'|' -f1)
    case "$current_mode" in
        Auto)
            fan_set full
            ;;
        Full)
            fan_set quiet
            ;;
        *)
            fan_set auto
            ;;
    esac
}

power_status() {
    local gov pp
    gov=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor 2>/dev/null || echo "")
    pp=$(powerprofilesctl get 2>/dev/null || echo "")

    if [ "$gov" = "performance" ]; then
        echo "Performance"
    elif [ "$pp" = "power-saver" ] || [ "$gov" = "powersave" ]; then
        echo "Power Saver"
    else
        echo "Balanced"
    fi
}

power_set() {
    local target="$1"
    case "$target" in
        saver|"Power Saver")
            powerprofilesctl set power-saver 2>/dev/null || true
            echo 0 > /sys/devices/system/cpu/cpufreq/boost 2>/dev/null || true
            for f in /sys/devices/system/cpu/cpu*/cpufreq/scaling_max_freq; do
                [ -f "$f" ] && echo 1700000 > "$f" 2>/dev/null || true
            done
            for g in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
                [ -f "$g" ] && echo powersave > "$g" 2>/dev/null || true
            done
            if command -v ryzenadj >/dev/null 2>&1; then
                ryzenadj --stapm-limit=8000 --fast-limit=10000 --slow-limit=8000 --tctl-temp=70 >/dev/null 2>&1 || true
            fi
            ;;
        balanced|Balanced)
            powerprofilesctl set balanced 2>/dev/null || true
            echo 1 > /sys/devices/system/cpu/cpufreq/boost 2>/dev/null || true
            for f in /sys/devices/system/cpu/cpu*/cpufreq/scaling_max_freq; do
                [ -f "$f" ] && echo 2100000 > "$f" 2>/dev/null || true
            done
            for g in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
                [ -f "$g" ] && echo schedutil > "$g" 2>/dev/null || true
            done
            if command -v ryzenadj >/dev/null 2>&1; then
                ryzenadj --stapm-limit=15000 --fast-limit=18000 --slow-limit=15000 --tctl-temp=80 >/dev/null 2>&1 || true
            fi
            ;;
        performance|Performance)
            powerprofilesctl set balanced 2>/dev/null || true
            echo 1 > /sys/devices/system/cpu/cpufreq/boost 2>/dev/null || true
            for f in /sys/devices/system/cpu/cpu*/cpufreq/scaling_max_freq; do
                [ -f "$f" ] && echo 2100000 > "$f" 2>/dev/null || true
            done
            for g in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
                [ -f "$g" ] && echo performance > "$g" 2>/dev/null || true
            done
            if command -v ryzenadj >/dev/null 2>&1; then
                ryzenadj --stapm-limit=25000 --fast-limit=28000 --slow-limit=25000 --tctl-temp=85 >/dev/null 2>&1 || true
            fi
            ;;
        *)
            echo "Unknown power target: $target" >&2
            exit 1
            ;;
    esac
}

power_cycle() {
    local current
    current=$(power_status)
    case "$current" in
        Balanced)
            power_set performance
            ;;
        Performance)
            power_set saver
            ;;
        *)
            power_set balanced
            ;;
    esac
}

charge_status() {
    local end
    end=$(cat /sys/class/power_supply/BAT0/charge_control_end_threshold 2>/dev/null || echo "100")
    if [ "$end" -le 85 ]; then
        echo "limited|${end}% Limit"
    else
        echo "full|100% Full"
    fi
}

charge_set() {
    local stop="${1:-100}"
    local start="${2:-96}"
    if [ "$stop" -ge 100 ]; then
        start=96
        stop=100
    fi
    echo "$start" > /sys/class/power_supply/BAT0/charge_control_start_threshold 2>/dev/null || true
    echo "$stop" > /sys/class/power_supply/BAT0/charge_control_end_threshold 2>/dev/null || true
}

charge_toggle() {
    local end
    end=$(cat /sys/class/power_supply/BAT0/charge_control_end_threshold 2>/dev/null || echo "100")
    if [ "$end" -le 85 ]; then
        charge_set 100 96
    else
        charge_set 80 75
    fi
}

case "$1" in
    charge-status)
        charge_status
        ;;
    charge-toggle)
        charge_toggle
        ;;
    charge-full)
        charge_set 100 96
        ;;
    charge-set)
        charge_set "$2" "$3"
        ;;
    fan-status)
        fan_status
        ;;
    fan-set)
        fan_set "$2"
        ;;
    fan-cycle)
        fan_cycle
        ;;
    power-status)
        power_status
        ;;
    power-set)
        power_set "$2"
        ;;
    power-cycle)
        power_cycle
        ;;
    *)
        echo "Usage: $0 {fan-status|fan-set <auto|full|quiet>|fan-cycle|power-status|power-set <saver|balanced|performance>|power-cycle}" >&2
        exit 1
        ;;
esac
