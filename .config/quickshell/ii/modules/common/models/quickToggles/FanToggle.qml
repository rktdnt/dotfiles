import QtQuick
import Quickshell
import Quickshell.Io
import qs.services
import qs.modules.common
import qs.modules.common.functions
import qs.modules.common.widgets

QuickToggleModel {
    id: root
    name: Translation.tr("Fan Speed")
    statusText: Translation.tr("Auto")
    icon: "mode_fan"
    toggled: false
    tooltipText: Translation.tr("Fan Control | Click to cycle: Auto -> Full -> Quiet")

    function parseOutput(text) {
        if (!text) return;
        var parts = text.trim().split("|");
        if (parts.length < 3) return;
        var mode = parts[0];
        var speed = parts[1];
        var level = parts[2];

        if (mode === "Auto") {
            root.icon = "mode_fan";
            root.statusText = (speed && speed !== "0") ? "Auto (" + speed + " RPM)" : "Auto (Silent)";
            root.toggled = false;
        } else if (mode === "Full") {
            root.icon = "cyclone";
            root.statusText = (speed && speed !== "0") ? "Full (" + speed + " RPM)" : "Full Speed";
            root.toggled = true;
        } else if (mode === "Quiet") {
            root.icon = "air";
            root.statusText = (speed && speed !== "0") ? "Quiet (" + speed + " RPM)" : "Quiet";
            root.toggled = true;
        } else {
            root.icon = "mode_fan";
            root.statusText = mode + " (" + speed + " RPM)";
            root.toggled = false;
        }
    }

    mainAction: () => {
        cycleProc.running = true;
    }

    Process {
        id: cycleProc
        command: ["sudo", "/home/rypl/.config/quickshell/ii/scripts/thinkpad-control.sh", "fan-cycle"]
        onExited: {
            statusProc.running = true;
        }
    }

    Process {
        id: statusProc
        running: true
        command: ["/home/rypl/.config/quickshell/ii/scripts/thinkpad-control.sh", "fan-status"]
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
            if (!statusProc.running && !cycleProc.running) {
                statusProc.running = true;
            }
        }
    }
}
