-- Ensure hyprbars is loaded before configuring plugin keywords
pcall(hl.plugin.load, "/var/cache/hyprpm/rypl/hyprland-plugins/hyprbars.so")

-- macOS Aesthetics: Subtle borders, deep drop shadows, and rounded corners
hl.config({
    general = {
        border_size = 1,
        col = {
            active_border = "rgba(ffffff28)",
            inactive_border = "rgba(00000018)"
        },
        resize_on_border = true
    },
    decoration = {
        rounding = 12,
        shadow = {
            enabled = true,
            range = 35,
            render_power = 4,
            color = "rgba(00000066)",
            color_inactive = "rgba(00000033)"
        },
        dim_inactive = true,
        dim_strength = 0.05
    },
    plugin = {
        hyprbars = {
            bar_height = 28,
            bar_color = "rgba(383838ee)",
            ["col.text"] = "rgba(ffffffcc)",
            bar_text_size = 10,
            bar_text_font = "JetBrains Mono Nerd Font",
            bar_button_padding = 12,
            bar_padding = 10,
            bar_buttons_alignment = "left",
            bar_precedence_over_border = true,
            bar_part_of_window = true,
            -- Traffic lights buttons: color, size, icon, on-click
            ["hyprbars-button"] = {
                "rgb(ff5f57), 12, , hyprctl dispatch killactive",
                "rgb(febc2e), 12, , hyprctl dispatch togglefloating",
                "rgb(28c840), 12, , hyprctl dispatch fullscreen 1",
            }
        }
    }
})

-- ── Ultra-Smooth macOS Fluid Animations ──
hl.curve("fluentDecel", {
    type = "bezier",
    points = {{0.16, 1}, {0.3, 1}}
})
hl.curve("macEase", {
    type = "bezier",
    points = {{0.25, 1}, {0.35, 1}}
})

-- Windows
hl.animation({
    leaf = "windowsIn",
    enabled = true,
    speed = 4.5,
    bezier = "fluentDecel",
    style = "popin 88%"
})
hl.animation({
    leaf = "windowsOut",
    enabled = true,
    speed = 3.5,
    bezier = "fluentDecel",
    style = "popin 92%"
})
hl.animation({
    leaf = "windowsMove",
    enabled = true,
    speed = 4.5,
    bezier = "fluentDecel",
    style = "slide"
})
hl.animation({
    leaf = "fadeIn",
    enabled = true,
    speed = 3.5,
    bezier = "fluentDecel"
})
hl.animation({
    leaf = "fadeOut",
    enabled = true,
    speed = 3.0,
    bezier = "fluentDecel"
})
hl.animation({
    leaf = "border",
    enabled = true,
    speed = 8.0,
    bezier = "fluentDecel"
})

-- Layers (Spotlight, Control Center, dialogs)
hl.animation({
    leaf = "layersIn",
    enabled = true,
    speed = 3.5,
    bezier = "fluentDecel",
    style = "popin 92%"
})
hl.animation({
    leaf = "layersOut",
    enabled = true,
    speed = 3.0,
    bezier = "fluentDecel",
    style = "popin 94%"
})
hl.animation({
    leaf = "fadeLayersIn",
    enabled = true,
    speed = 3.0,
    bezier = "fluentDecel"
})
hl.animation({
    leaf = "fadeLayersOut",
    enabled = true,
    speed = 2.5,
    bezier = "fluentDecel"
})

-- Workspaces
hl.animation({
    leaf = "workspaces",
    enabled = true,
    speed = 4.5,
    bezier = "fluentDecel",
    style = "slide"
})
hl.animation({
    leaf = "specialWorkspaceIn",
    enabled = true,
    speed = 4.0,
    bezier = "fluentDecel",
    style = "slidevert"
})
hl.animation({
    leaf = "specialWorkspaceOut",
    enabled = true,
    speed = 3.0,
    bezier = "fluentDecel",
    style = "slidevert"
})
