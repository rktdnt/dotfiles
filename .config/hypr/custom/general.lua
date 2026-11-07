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
