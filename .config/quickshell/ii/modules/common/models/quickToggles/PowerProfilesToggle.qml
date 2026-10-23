import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.UPower
import qs
import qs.services
import qs.modules.common
import qs.modules.common.functions
import qs.modules.common.widgets

QuickToggleModel {
    id: root
    name: Translation.tr("Power Profile")
    property string customProfile: "Balanced"

    toggled: customProfile !== "Balanced"
    icon: switch(customProfile) {
        case "Power Saver": return "energy_savings_leaf"
        case "Balanced": return "airwave"
        case "Performance": return "local_fire_department"
        default: return "airwave"
    }
    statusText: customProfile

    mainAction: () => {
        if (PowerProfiles.hasPerformanceProfile) {
            switch(PowerProfiles.profile) {
                case PowerProfile.PowerSaver: PowerProfiles.profile = PowerProfile.Balanced; break;
                case PowerProfile.Balanced: PowerProfiles.profile = PowerProfile.Performance; break;
                case PowerProfile.Performance: PowerProfiles.profile = PowerProfile.PowerSaver; break;
            }
        } else {
            cycleProc.running = true;
        }
    }

    Process {
        id: cycleProc
        command: ["sudo", "/home/rypl/.config/quickshell/ii/scripts/thinkpad-control.sh", "power-cycle"]
        onExited: {
            statusProc.running = true;
        }
    }

    Process {
        id: statusProc
        running: true
        command: ["/home/rypl/.config/quickshell/ii/scripts/thinkpad-control.sh", "power-status"]
        stdout: StdioCollector {
            id: statusCollector
            onStreamFinished: {
                var out = statusCollector.text.trim();
                if (out.length > 0) {
                    root.customProfile = out;
                }
            }
        }
    }

    Timer {
        interval: 3000
        running: !PowerProfiles.hasPerformanceProfile
        repeat: true
        onTriggered: {
            if (!statusProc.running && !cycleProc.running) {
                statusProc.running = true;
            }
        }
    }

    tooltipText: Translation.tr("Click to cycle: Balanced -> Performance -> Power Saver")
}
