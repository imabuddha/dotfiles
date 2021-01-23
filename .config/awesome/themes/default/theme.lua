---------------------------
-- jdm awesome theme --
---------------------------

local theme_assets = require("beautiful.theme_assets")
local xresources = require("beautiful.xresources")
local gears = require("gears")

local dpi = xresources.apply_dpi

local gfs = require("gears.filesystem")
local themes_path = gfs.get_themes_dir()

local theme = {}

theme.confdir = os.getenv("HOME") .. "/.config/awesome/themes/default"

theme.font          = "MesloGS NF Regular 10"
theme.textclock_font= "MesloGS NF Bold 10"

theme.bg_normal     = "#1A1A1A"
theme.bg_focus      = "#002957"
theme.bg_urgent     = "#D43B3B"
theme.bg_minimize   = "#2E2E2E"
theme.bg_systray    = theme.bg_normal

theme.fg_normal     = "#6299F6"
theme.fg_focus      = "#E0E0E0"
theme.fg_urgent     = "#ffffff"
theme.fg_minimize   = "#CFCFCF"

theme.useless_gap   = dpi(2)
theme.systray_icon_spacing = dpi(4)

theme.border_width  = dpi(1)
theme.border_normal = "#1A1D21"
theme.border_focus  = "#6287C4"
theme.border_marked = "#91231c"
theme.border_color_active = "#E09100"

-- hotkeys popup
theme.hotkeys_font = "MesloGS NF Bold 9"
theme.hotkeys_description_font = "MesloGS NF Regular 8"

theme.hotkeys_group_margin = dpi(10)
theme.hotkeys_border_width = dpi(3)

theme.hotkeys_border_color = "#E09100"
theme.hotkeys_modifiers_fg = "#68A0C1"
theme.hotkeys_fg = "#E6E6E6"
theme.hotkeys_label_fg = "#000000"

-- taglist
theme.taglist_font = "MesloGS NF Bold 20"

theme.taglist_fg_focus = theme.bg_normal
theme.taglist_bg_focus = "#4D658C"

theme.taglist_fg_occupied = "#788EB3"
theme.taglist_bg_occupied = "#213452"

theme.taglist_fg_empty = theme.taglist_bg_focus
theme.taglist_bg_empty = theme.taglist_bg_occupied

theme.taglist_shape = gears.shape.powerline
theme.taglist_spacing = dpi(-10)

-- my powerline
--theme.separators_height = dpi(24)
--theme.separators_width = dpi(12)
theme.powerline_bg1 = "#213452"
theme.powerline_bg2 = "#0D2347"

-- widget icons from nerd font
theme.widget_icon_color = "#BEBEBE"
theme.widget_text_color = "#6299F6"

theme.widget_neticon  = "  "   --  or ⇵

-- Variables set for theming the menu:
theme.menu_submenu_icon = themes_path.."default/submenu.png"
theme.menu_height = dpi(24)
theme.menu_width  = dpi(200)

-- titlebar
theme.titlebar_close_button_normal = themes_path.."default/titlebar/close_normal.png"
theme.titlebar_close_button_focus  = themes_path.."default/titlebar/close_focus.png"

theme.titlebar_minimize_button_normal = themes_path.."default/titlebar/minimize_normal.png"
theme.titlebar_minimize_button_focus  = themes_path.."default/titlebar/minimize_focus.png"

theme.titlebar_ontop_button_normal_inactive = themes_path.."default/titlebar/ontop_normal_inactive.png"
theme.titlebar_ontop_button_focus_inactive  = themes_path.."default/titlebar/ontop_focus_inactive.png"
theme.titlebar_ontop_button_normal_active = themes_path.."default/titlebar/ontop_normal_active.png"
theme.titlebar_ontop_button_focus_active  = themes_path.."default/titlebar/ontop_focus_active.png"

theme.titlebar_sticky_button_normal_inactive = themes_path.."default/titlebar/sticky_normal_inactive.png"
theme.titlebar_sticky_button_focus_inactive  = themes_path.."default/titlebar/sticky_focus_inactive.png"
theme.titlebar_sticky_button_normal_active = themes_path.."default/titlebar/sticky_normal_active.png"
theme.titlebar_sticky_button_focus_active  = themes_path.."default/titlebar/sticky_focus_active.png"

theme.titlebar_floating_button_normal_inactive = themes_path.."default/titlebar/floating_normal_inactive.png"
theme.titlebar_floating_button_focus_inactive  = themes_path.."default/titlebar/floating_focus_inactive.png"
theme.titlebar_floating_button_normal_active = themes_path.."default/titlebar/floating_normal_active.png"
theme.titlebar_floating_button_focus_active  = themes_path.."default/titlebar/floating_focus_active.png"

theme.titlebar_maximized_button_normal_inactive = themes_path.."default/titlebar/maximized_normal_inactive.png"
theme.titlebar_maximized_button_focus_inactive  = themes_path.."default/titlebar/maximized_focus_inactive.png"
theme.titlebar_maximized_button_normal_active = themes_path.."default/titlebar/maximized_normal_active.png"
theme.titlebar_maximized_button_focus_active  = themes_path.."default/titlebar/maximized_focus_active.png"

theme.wallpaper = themes_path.."default/background.png"

-- You can use your own layout icons like this:
theme.layout_fairh = themes_path.."default/layouts/fairhw.png"
theme.layout_fairv = themes_path.."default/layouts/fairvw.png"
theme.layout_floating  = themes_path.."default/layouts/floatingw.png"
theme.layout_magnifier = themes_path.."default/layouts/magnifierw.png"
theme.layout_max = themes_path.."default/layouts/maxw.png"
theme.layout_fullscreen = themes_path.."default/layouts/fullscreenw.png"
theme.layout_tilebottom = themes_path.."default/layouts/tilebottomw.png"
theme.layout_tileleft   = themes_path.."default/layouts/tileleftw.png"
theme.layout_tile = themes_path.."default/layouts/tilew.png"
theme.layout_tiletop = themes_path.."default/layouts/tiletopw.png"
theme.layout_spiral  = themes_path.."default/layouts/spiralw.png"
theme.layout_dwindle = themes_path.."default/layouts/dwindlew.png"
theme.layout_cornernw = themes_path.."default/layouts/cornernww.png"
theme.layout_cornerne = themes_path.."default/layouts/cornernew.png"
theme.layout_cornersw = themes_path.."default/layouts/cornersww.png"
theme.layout_cornerse = themes_path.."default/layouts/cornersew.png"

-- from awesome-copycats
theme.widget_cpu = theme.confdir .. "/icons/cpu.png"
theme.widget_mem = theme.confdir .. "/icons/mem.png"
theme.widget_temp = theme.confdir .. "/icons/temp.png"

-- use raspi
theme.awesome_icon = "/usr/share/raspberrypi-artwork/raspberry-pi-logo.svg"

-- Define the icon theme for application icons. If not set then the icons
-- from /usr/share/icons and /usr/share/icons/hicolor will be used.
theme.icon_theme = nil

return theme

-- vim: filetype=lua:expandtab:shiftwidth=4:tabstop=8:softtabstop=4:textwidth=80
