local wezterm = require "wezterm"
local hostname = wezterm.hostname():lower()
local action = wezterm.action

local function merge(a, b)
   for k, v in pairs(b) do
      if a[k] == nil then
         a[k] = v
      end
   end
end

local config = {
   keys = {
      { key = 'c',
      mods = 'CTRL',
      action = wezterm.action_callback(function(window, pane)
      selection_text = window:get_selection_text_for_pane(pane)
      is_selection_active = string.len(selection_text) ~= 0
      if is_selection_active then
         window:perform_action(wezterm.action.CopyTo('Clipboard'), pane)
      else
         window:perform_action(wezterm.action.SendKey{ key='c', mods='CTRL' }, pane)
      end
      end),
   },
   -- paste from the clipboard
   { key = 'v', mods = 'CTRL', action = wezterm.action.PasteFrom 'Clipboard' },
},
}

do
local ok, localconf = pcall(require, hostname)
if ok then
   merge(config, localconf)
end
end

return config
