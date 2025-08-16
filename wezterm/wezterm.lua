-- Pull in the wezterm API
local wezterm = require("wezterm")

-- Maximize window at startup
wezterm.on("gui-startup", function(cmd)
	local mux = wezterm.mux
	local _, _, window = mux.spawn_window(cmd or {})
	window:gui_window():maximize()
end)

-- Maximize window on resize
wezterm.on("window-resized", function(window, _)
	window:maximize()
end)

-- This table will hold the configuration.
local config = {}

-- In newer versions of wezterm, use the config_builder which will
-- help provide clearer error messages
if wezterm.config_builder then
	config = wezterm.config_builder()
end

-- This is where you actually apply your config choices

-- Run tmux at sturtup
-- config.default_prog = { "/bin/zsh", "-l", "-c", "tmux attach || tmux" }

config.use_resize_increments = true

-- Disable the title bar but enable the resizable border
config.window_decorations = "RESIZE | MACOS_FORCE_DISABLE_SHADOW"

-- When there is only a single tab, the tab bar is hidden
config.hide_tab_bar_if_only_one_tab = true

-- config.color_scheme = "Gruvbox Dark (Gogh)"
-- config.color_scheme = "Tokyo Night"
config.color_scheme = "Kanagawa (Gogh)"

config.font = wezterm.font("Mononoki Nerd Font")
config.font_size = 20.0

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

-- Load custom config if it exists and merge it with defaults
local custom_module_name = "custom"
local path = wezterm.config_dir .. "/" .. custom_module_name .. ".lua"
local f = io.open(path, "r")
if f ~= nil then
	io.close(f)

	local custom = require(custom_module_name)
	for k, v in pairs(custom) do
		config[k] = v
	end
end

-- and finally, return the configuration to wezterm
return config
