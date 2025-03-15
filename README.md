# My WezTerm config

This repository contains my custom WezTerm configuration for Linux, macOS, and potentially Windows.

For the best experience, use it alongside my [config-tmux](https://github.com/reybits/config-tmux.git) repository.

## Install

```sh
git clone https://github.com/reybits/config-wezterm.git ~/.config/wezterm
```

## Customization

Cusomization is done through the `~/.config/wezterm/custom.lua` file. This file is loaded by WezTerm at startup and allows you to customize the terminal in a variety of ways.

```lua
-- ~/.config/wezterm/custom.lua

local config = {}

local wezterm = require("wezterm")

config.font = wezterm.font("JetBrains Mono")

if os.getenv("XDG_CURRENT_DESKTOP") == "Hyprland" then
	config.enable_wayland = false
	config.font_size = 24.0
else
	config.font_size = 18.0
end

return config
```

## Related resources

- [WezTerm homepage](https://wezterm.org)
- [WezTerm on GitHub](https://github.com/wezterm/wezterm/)
- [Nerd Fonts](https://www.nerdfonts.com/)
