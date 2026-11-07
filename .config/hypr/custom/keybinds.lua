hl.bind("CTRL+SUPER+ALT+Slash", hl.dsp.exec_cmd("xdg-open ~/.config/hypr/custom/keybinds.lua"), {description = "Edit user keybinds"} )

-- macOS Window Management Binds
hl.bind("SUPER + W", hl.dsp.window.close(), { description = "Window: Close (Cmd+W)" })
hl.bind("SUPER + M", hl.dsp.exec_cmd("hyprctl dispatch movetoworkspacesilent special:minimized"), { description = "Window: Minimize (Cmd+M)" })
hl.bind("SUPER + SHIFT + M", hl.dsp.exec_cmd("hyprctl dispatch togglespecialworkspace minimized"), { description = "Window: Restore Minimized" })
hl.bind("SUPER + T", hl.dsp.window.float({ action = "toggle" }), { description = "Window: Toggle Float/Tile" })
hl.bind("SUPER + comma", hl.dsp.exec_cmd("qs -c MacShell ipc call settings open"), { description = "Preferences (Cmd+,)" })
