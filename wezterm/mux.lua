local M = {}

function M.apply(config, wezterm)
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
end

return M
