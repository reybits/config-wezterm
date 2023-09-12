-- Pull in the wezterm API
local wezterm = require("wezterm")

-- Maximize window at startup
wezterm.on("gui-startup", function()
	local mux = wezterm.mux
	local _, _, window = mux.spawn_window({})
	window:gui_window():maximize()
end)

-- This table will hold the configuration.
local config = {}

-- In newer versions of wezterm, use the config_builder which will
-- help provide clearer error messages
if wezterm.config_builder then
	config = wezterm.config_builder()
end

-- This is where you actually apply your config choices

config.window_padding = {
	left = 20,
	right = 20,
	top = 20,
	bottom = 0,
}

-- Disable the title bar but enable the resizable border
config.window_decorations = "RESIZE"

-- When there is only a single tab, the tab bar is hidden
config.hide_tab_bar_if_only_one_tab = true

config.color_scheme = "Gruvbox Dark (Gogh)"

config.font = wezterm.font("JetBrains Mono")
config.font_size = 18.0

config.font_rules = {
	{
		intensity = "Bold",
		italic = false,
		font = wezterm.font("JetBrains Mono", { weight = "Bold", style = "Normal" }),
	},
	{
		intensity = "Normal",
		italic = true,
		font = wezterm.font("JetBrains Mono", { weight = "Bold", style = "Italic" }),
	},
}

-- and finally, return the configuration to wezterm
return config
