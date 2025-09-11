local wezterm = require("wezterm")

return {
	-- TODO: fonts
	-- harfbuzz_features = { 'zero', 'cv02', 'cv03' },
	-- font = wezterm.font_with_fallback {
	--   'Maple Mono',
	--   'Twitter Color Emoji',
	--   'Nerd Font Symbols',
	-- },
	-- font_size = 8.5,
	-- line_height = 1.2,
	color_scheme = "Catppuccin Mocha",

	enable_tab_bar = false,
	enable_scroll_bar = true,
	window_padding = {
		left = 0,
		right = 8,
		top = 0,
		bottom = 0,
	},

	unicode_version = 14,

	swallow_mouse_click_on_window_focus = true,
}
