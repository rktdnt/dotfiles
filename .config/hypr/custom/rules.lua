-- macOS 1:1 Floating Window Management
-- All application windows open as floating, centered windows like on macOS
hl.window_rule({
    match = { class = ".*" },
    float = true,
    center = true
})

-- Don't float full-screen games or specific special utilities
hl.window_rule({ match = { class = "^(steam_app_.*)$" }, float = false })
hl.window_rule({ match = { class = "^(gamescope)$" }, float = false })
