-- Pull in the wezterm API
local wezterm = require("wezterm")

-- Maximize window at startup
wezterm.on("gui-startup", function(cmd)
	local mux = wezterm.mux
	local _, _, window = mux.spawn_window(cmd or {})
	window:gui_window():maximize()
end)

-- Center the terminal grid by distributing leftover pixels evenly as padding
local function center_padding(window, pane)
	local overrides = window:get_config_overrides() or {}

	-- Reset padding to get accurate cell dimensions
	overrides.window_padding = { left = 0, right = 0, top = 0, bottom = 0 }
	window:set_config_overrides(overrides)

	-- Measure after layout settles with zero padding
	wezterm.time.call_after(0.1, function()
		local win_dims = window:get_dimensions()
		local tab_dims = pane:tab():get_size()

		if tab_dims.cols > 0 and tab_dims.rows > 0 then
			local cell_width = tab_dims.pixel_width / tab_dims.cols
			local cell_height = tab_dims.pixel_height / tab_dims.rows

			local extra_x = win_dims.pixel_width - math.floor(win_dims.pixel_width / cell_width) * cell_width
			local extra_y = win_dims.pixel_height - math.floor(win_dims.pixel_height / cell_height) * cell_height

			overrides = window:get_config_overrides() or {}
			overrides.window_padding = {
				left = math.floor(extra_x / 2),
				right = math.ceil(extra_x / 2),
				top = math.floor(extra_y / 2),
				bottom = math.ceil(extra_y / 2),
			}
			window:set_config_overrides(overrides)
		end
	end)
end

-- Custom event to trigger recentering
wezterm.on("center-padding", function(window, pane)
	center_padding(window, pane)
end)

-- Maximize window on resize and center the grid
wezterm.on("window-resized", function(window, pane)
	window:maximize()
	center_padding(window, pane)
end)


-- This table will hold the configuration.
local config = {}

-- In newer versions of wezterm, use the config_builder which will
-- help provide clearer error messages
if wezterm.config_builder then
	config = wezterm.config_builder()
end

-- This is where you actually apply your config choices

-- To use WezTerm's built-in multiplexer instead of tmux,
-- uncomment the following line:
-- require("mux").apply(config, wezterm)

config.use_resize_increments = true

-- Override font size keys to also recenter the grid
config.keys = {
	{
		key = "=",
		mods = "CMD",
		action = wezterm.action.Multiple({
			wezterm.action.IncreaseFontSize,
			wezterm.action.EmitEvent("center-padding"),
		}),
	},
	{
		key = "-",
		mods = "CMD",
		action = wezterm.action.Multiple({
			wezterm.action.DecreaseFontSize,
			wezterm.action.EmitEvent("center-padding"),
		}),
	},
	{
		key = "0",
		mods = "CMD",
		action = wezterm.action.Multiple({
			wezterm.action.ResetFontSize,
			wezterm.action.EmitEvent("center-padding"),
		}),
	},
	{
		key = "=",
		mods = "CTRL",
		action = wezterm.action.Multiple({
			wezterm.action.IncreaseFontSize,
			wezterm.action.EmitEvent("center-padding"),
		}),
	},
	{
		key = "-",
		mods = "CTRL",
		action = wezterm.action.Multiple({
			wezterm.action.DecreaseFontSize,
			wezterm.action.EmitEvent("center-padding"),
		}),
	},
	{
		key = "0",
		mods = "CTRL",
		action = wezterm.action.Multiple({
			wezterm.action.ResetFontSize,
			wezterm.action.EmitEvent("center-padding"),
		}),
	},
}

-- Disable the title bar (TITLE) but enable the resizable border (RESIZE).
-- On macOS, also disable the shadow (MACOS_FORCE_DISABLE_SHADOW)
-- that is normally drawn around the window.
config.window_decorations = "RESIZE | MACOS_FORCE_DISABLE_SHADOW"

-- When there is only a single tab, the tab bar is hidden
config.hide_tab_bar_if_only_one_tab = true

-- config.color_scheme = "Gruvbox Dark (Gogh)"
-- config.color_scheme = "Tokyo Night"
config.color_scheme = "Kanagawa (Gogh)"

-- local font_name = "Mononoki Nerd Font"
-- config.font_size = 18.0
local font_name = "JetBrainsMono Nerd Font"
config.font = wezterm.font(font_name)
config.font_size = 19.0
config.line_height = 0.9

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

config.font_rules = {
	-- non italic
	{
		intensity = "Normal",
		italic = false,
		font = wezterm.font(font_name, { weight = "Regular", style = "Normal" }),
	},
	{
		intensity = "Bold",
		italic = false,
		font = wezterm.font(font_name, { weight = "Bold", style = "Normal" }),
	},

	-- italic
	{
		intensity = "Normal",
		italic = true,
		font = wezterm.font(font_name, { weight = "Regular", style = "Italic" }),
	},
	{
		intensity = "Bold",
		italic = true,
		font = wezterm.font(font_name, { weight = "Bold", style = "Italic" }),
	},
}

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
