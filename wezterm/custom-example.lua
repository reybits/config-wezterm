local config = {}

local wezterm = require("wezterm")

-- config.font = wezterm.font("JetBrainsMonoNL Nerd Font Mono")
config.font = wezterm.font("JetBrains Mono")

if os.getenv("XDG_CURRENT_DESKTOP") == "Hyprland" then
	config.enable_wayland = false
	config.font_size = 24.0
else
	config.font_size = 18.0
end

return config
