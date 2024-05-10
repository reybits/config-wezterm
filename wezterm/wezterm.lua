-- Pull in the wezterm API
local wezterm = require("wezterm")

-- Maximize window at startup
wezterm.on("gui-startup", function(cmd)
	local mux = wezterm.mux
	local _, _, window = mux.spawn_window(cmd or {})
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

config.use_resize_increments = true

-- Disable the title bar but enable the resizable border
config.window_decorations = "RESIZE | MACOS_FORCE_DISABLE_SHADOW"

-- When there is only a single tab, the tab bar is hidden
config.hide_tab_bar_if_only_one_tab = true

-- config.color_scheme = "Gruvbox Dark (Gogh)"
config.color_scheme = "Tokyo Night"

config.font = wezterm.font("JetBrains Mono")
if os.getenv("XDG_CURRENT_DESKTOP") == "Hyprland" then
	config.enable_wayland = false
	config.font_size = 24.0
else
	config.font_size = 18.0
end

-- Disable ligatures in most fonts.
-- https://wezfurlong.org/wezterm/config/font-shaping.html#advanced-font-shaping-options
-- https://learn.microsoft.com/en-us/typography/opentype/spec/featurelist
config.harfbuzz_features = {
	-- ==, >=, <=, !=, ===
	"calt=0", -- Contextual Alternates.
	"clig=0", -- Contextual Ligatures. (It makes no difference whether this option is disabled or enabled)
	"liga=0", -- Standard Ligatures.

	-- Slashed Zero: 0
	"zero",
}

--[[
config.font_rules = {
	-- non italic
	{
		intensity = "Normal",
		italic = false,
		font = wezterm.font("JetBrains Mono", { weight = "Regular", style = "Normal" }),
	},
	{
		intensity = "Bold",
		italic = false,
		font = wezterm.font("JetBrains Mono", { weight = "Bold", style = "Normal" }),
	},

	-- italic
	{
		intensity = "Normal",
		italic = true,
		font = wezterm.font("JetBrains Mono", { weight = "Regular", style = "Italic" }),
	},
	{
		intensity = "Bold",
		italic = true,
		font = wezterm.font("JetBrains Mono", { weight = "Bold", style = "Italic" }),
	},
}
--]]

-- and finally, return the configuration to wezterm
return config
