#!/bin/sh
# maclock.sh: lock the screen now (kept so older hypridle / keybind setups keep working).
exec sh "/home/rypl/.config/quickshell/MacLock/lock-via-ipc.sh" "$@"
