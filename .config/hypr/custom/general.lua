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
    }
})
