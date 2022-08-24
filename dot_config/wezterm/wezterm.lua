local wezterm = require 'wezterm'
local act = wezterm.action

return {

  -- general
  window_close_confirmation = 'NeverPrompt',
  default_prog = { '/usr/local/bin/fish', '-l' },

  -- font
  font = wezterm.font("Fira Code")                             	, -- [JetBrains Mono]
  font_size = 14.0                                                       	, -- [12.0]

  -- Colors
  color_scheme = "DoomOne",

  -- appearance
  enable_tab_bar              	= false	, -- [true]

  -- keybinds
  keys = {
    {
      key = 'w',
      mods = 'CMD',
      action = wezterm.action.CloseCurrentTab { confirm = false },
    },
    {
      key = 'h',
      mods = 'CTRL',
      action = act.ActivatePaneDirection 'Left',
    },
    {
      key = 'l',
      mods = 'CTRL',
      action = act.ActivatePaneDirection 'Right',
    },
    {
      key = 'k',
      mods = 'CTRL',
      action = act.ActivatePaneDirection 'Up',
    },
    {
      key = 'j',
      mods = 'CTRL',
      action = act.ActivatePaneDirection 'Down',
    },
  },

  -- define and autoconnect to local server
  unix_domains = {
    {
      name = 'unix',
    },
  },
  default_gui_startup_args = { 'connect', 'unix' },
}
