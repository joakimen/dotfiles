local wezterm = require 'wezterm'
local act = wezterm.action
local mods = "CTRL|SHIFT"

-- shell
local shell = '/opt/homebrew/bin/fish'

-- fonts
local font_size = 15.0
local font_name = "Fira Code"
-- local font_name = "Liga Menlo"

-- colors
-- local light_theme = 'Builtin Solarized Light'
-- local light_theme = 'Catppuccin Latte'
local light_theme = 'Solarized (light) (terminal.sexy)'
local dark_theme = 'Catppuccin Mocha'
-- local dark_theme = 'Batman'
-- local dark_theme = "DoomOne"
-- local dark_theme = "Catppuccin Mocha"
-- local dark_theme = "Snazzy"
-- local dark_theme = "Zenburn"

-- load colorscheme based on system theme.
local function get_color_scheme()
	local system_theme = wezterm.gui.get_appearance()
	return system_theme:find 'Dark' and dark_theme or light_theme
end

-- show workspace name in the lower right corner
wezterm.on('update-right-status', function(window)
	window:set_right_status(window:active_workspace())
end)

local keys = {
	{
		key = "Backspace",
		mods = mods,
		action = act.ClearScrollback("ScrollbackAndViewport"),
	},
	{
		key = "E",
		mods = mods,
		action = act.CharSelect({ copy_on_select = false }),
	},
	{
		key = "s",
		mods = "CTRL",
		action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }),
	},
	{
		key = "x",
		mods = "CTRL",
		action = act.SplitVertical({ domain = "CurrentPaneDomain" }),
	},
	{
		key = "W",
		mods = mods,
		action = act.CloseCurrentPane({ confirm = false }),
	},
	{
		key = "Home",
		mods = mods,
		action = "ScrollToTop",
	},
	{
		key = "H",
		mods = mods,
		action = act.ActivatePaneDirection("Left"),
	},
	{
		key = "L",
		mods = mods,
		action = act.ActivatePaneDirection("Right"),
	},
	{
		key = "K",
		mods = mods,
		action = act.ActivatePaneDirection("Up"),
	},
	{
		key = "J",
		mods = mods,
		action = act.ActivatePaneDirection("Down"),
	},

	-- Switch to the default workspace
	{
		key = 'y',
		mods = mods,
		action = act.SwitchToWorkspace {
			name = 'default',
		},
	},
	-- Switch to a monitoring workspace, which will have `top` launched into it
	{
		key = 'u',
		mods = mods,
		action = act.SwitchToWorkspace {
			name = 'monitoring',
			spawn = {
				args = { 'top' },
			},
		},
	},
	-- Create a new workspace with a random name and switch to it
	{
		key = 'i',
		mods = mods,
		action = act.SwitchToWorkspace
	},
	-- Show the launcher in fuzzy selection mode and have it list all workspaces
	-- and allow activating one.
	{
		key = '9',
		mods = 'ALT',
		action = act.ShowLauncherArgs {
			flags = 'FUZZY|WORKSPACES',
		},
	},

}

return {
	default_prog                               = { shell, '-l' },
	font                                       = wezterm.font(font_name),
	font_size                                  = font_size,
	color_scheme                               = get_color_scheme(),
	tab_bar_at_bottom                          = true,
	use_fancy_tab_bar                          = false,
	keys                                       = keys,
	freetype_load_target                       = "HorizontalLcd",
	show_tabs_in_tab_bar                       = true,
	adjust_window_size_when_changing_font_size = false,

	-- define local multiplexing server
	unix_domains                               = {
		{
			name = 'unix',
		},
	},
	-- autoconnect to local multiplexing server
	default_gui_startup_args                   = { 'connect', 'unix' },
}
