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

-- Experimental support for WezTerm's built-in multiplexing.
-- Uncomment the following line to use it instead of tmux.
--[[
-- if you are *NOT* lazy-loading smart-splits.nvim (recommended)
local function is_vim(pane)
	-- this is set by the plugin, and unset on ExitPre in Neovim
	return pane:get_user_vars().IS_NVIM == "true"
end

local direction_keys = {
	h = "Left",
	j = "Down",
	k = "Up",
	l = "Right",
}

local function split_nav(resize_or_move, key)
	return {
		key = key,
		mods = resize_or_move == "resize" and "META" or "CTRL",
		action = wezterm.action_callback(function(win, pane)
			if is_vim(pane) then
				-- pass the keys through to vim/nvim
				win:perform_action({
					SendKey = { key = key, mods = resize_or_move == "resize" and "META" or "CTRL" },
				}, pane)
			else
				if resize_or_move == "resize" then
					win:perform_action({ AdjustPaneSize = { direction_keys[key], 3 } }, pane)
				else
					win:perform_action({ ActivatePaneDirection = direction_keys[key] }, pane)
				end
			end
		end),
	}
end

-- Leader is the same as my old tmux prefix
config.leader = {
	key = "b",
	mods = "CTRL",
	timeout_milliseconds = 1000,
}

-- Key bindings
config.keys = {
	-- splitting
	{
		mods = "LEADER",
		key = "-",
		action = wezterm.action.SplitVertical({ domain = "CurrentPaneDomain" }),
	},
	{
		mods = "LEADER",
		key = "|",
		action = wezterm.action.SplitHorizontal({ domain = "CurrentPaneDomain" }),
	},

	-- maximize/restore pane
	{
		mods = "LEADER",
		key = "z",
		action = wezterm.action.TogglePaneZoomState,
	},

	-- activate copy mode or vim mode
	{
		key = "[",
		mods = "LEADER",
		action = wezterm.action.ActivateCopyMode,
	},

	-- rotate panes
	{
		mods = "LEADER",
		key = "Space",
		action = wezterm.action.RotatePanes("Clockwise"),
	},
	-- show the pane selection mode, but have it swap the active and selected panes
	{
		mods = "LEADER",
		key = "0",
		action = wezterm.action.PaneSelect({
			mode = "SwapWithActive",
		}),
	},
	split_nav("move", "h"),
	split_nav("move", "j"),
	split_nav("move", "k"),
	split_nav("move", "l"),
}
--]]

config.use_resize_increments = true

-- Disable the title bar but enable the resizable border
config.window_decorations = "RESIZE | MACOS_FORCE_DISABLE_SHADOW"

-- When there is only a single tab, the tab bar is hidden
config.hide_tab_bar_if_only_one_tab = true

-- config.color_scheme = "Gruvbox Dark (Gogh)"
-- config.color_scheme = "Tokyo Night"
config.color_scheme = "Kanagawa (Gogh)"

-- config.font = wezterm.font("Mononoki Nerd Font")
-- config.font_size = 18.0
config.font = wezterm.font("JetBrainsMono Nerd Font")
config.font_size = 16.0
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
