import QtQuick
import Quickshell
import Quickshell.Io
import qs.services
import qs.modules.common
import qs.modules.common.functions
import qs.modules.common.widgets

QuickToggleModel {
    id: root
    name: Translation.tr("Battery Limit")
    statusText: Translation.tr("80% Limit")
    icon: "battery_saver"
    toggled: true
    tooltipText: Translation.tr("Battery Charge Limit | Click to toggle: 80% <-> 100%")

    function parseOutput(text) {
        if (!text) return;
        var parts = text.trim().split("|");
        if (parts.length < 2) return;
        var mode = parts[0];
        var desc = parts[1];

        if (mode === "limited") {
            root.icon = "battery_saver";
            root.statusText = desc;
            root.toggled = true;
        } else {
            root.icon = "battery_charging_full";
            root.statusText = desc;
            root.toggled = false;
        }
    }

    mainAction: () => {
        toggleProc.running = true;
    }

    Process {
        id: toggleProc
        command: ["sudo", "/home/rypl/.config/quickshell/ii/scripts/thinkpad-control.sh", "charge-toggle"]
        onExited: {
            statusProc.running = true;
        }
    }

    Process {
        id: statusProc
        running: true
        command: ["/home/rypl/.config/quickshell/ii/scripts/thinkpad-control.sh", "charge-status"]
        stdout: StdioCollector {
            id: statusCollector
            onStreamFinished: {
                root.parseOutput(statusCollector.text);
            }
        }
    }

    Timer {
        interval: 3000
        running: true
        repeat: true
        onTriggered: {
            if (!statusProc.running && !toggleProc.running) {
                statusProc.running = true;
            }
        }
    }
}
