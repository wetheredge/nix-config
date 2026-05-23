-- Based on <https://wezterm.org/config/lua/wezterm.gui/get_appearance.html>
local function get_color_scheme()
	local appearance = wezterm.gui and wezterm.gui.get_appearance() or "Dark"
	return appearance:find("Dark") and "Catppuccin Mocha" or "Catppuccin Latte"
end

return {
	-- TODO: fonts
	-- harfbuzz_features = { "zero", "cv02", "cv03" },
	font = wezterm.font_with_fallback({
		"Maple Mono",
		"Twitter Color Emoji",
		-- "Nerd Font Symbols",
	}),
	font_size = 10,
	line_height = 1.2,
	color_scheme = get_color_scheme(),

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
