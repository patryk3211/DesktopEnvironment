
local theme_assets = require("beautiful.theme_assets")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi

local gfs = require("gears.filesystem")
local themes_path = gfs.get_themes_dir()

local gears = require("gears")
local config = require("config")

local theme = {}

-- Default style variables
theme.font = "Hack Nerd Regular 12"

theme.bg_normal     = "#282828"
theme.bg_focus      = "#535d6c"
theme.bg_urgent     = "#ff0000"
theme.bg_minimize   = "#444444"
theme.bg_systray    = theme.bg_normal

theme.fg_normal     = "#aaaaaa"
theme.fg_focus      = "#ffffff"
theme.fg_urgent     = "#ffffff"
theme.fg_minimize   = "#ffffff"

theme.useless_gap   = dpi(2)
theme.border_width  = dpi(1)
theme.border_normal = "#000000"
theme.border_focus  = "#207bb8"
theme.border_marked = "#91231c"

theme.bg_systray = "#202020"
theme.systray_icon_spacing = 6

-- Base colors for taglist
theme.taglist_bg = "#181818"
theme.taglist_fg = "#ffffff"

-- Set other taglist colors
theme.taglist_fg_focus = theme.taglist_fg
theme.taglist_bg_focus = "#207bb8"
theme.taglist_fg_urgent = theme.taglist_fg
theme.taglist_bg_urgent = "#b32222"
theme.taglist_bg_occupied = theme.taglist_bg
theme.taglist_fg_occupied = theme.taglist_fg
theme.taglist_bg_empty = theme.taglist_bg
theme.taglist_fg_empty = "#999999"
theme.taglist_bg_volatile = "#00ff00" -- TODO
theme.taglist_fg_volatile = "#0000ff" -- TODO
theme.taglist_font = "Hack Nerd Regular 28"

-- Set info bar style
theme.clock_bg = "#181818"
theme.clock_fg = "#dddddd"

theme.prompt_popup_font = "Fira Mono 11"

theme.info_bg = "#404040"
theme.info_fg = "#ffffff"
theme.info_font = "Hack Nerd Regular 11"

theme.cpu_color = "#ffffff"
theme.ram_color = "#ffffff"

-- Main menu
theme.mm_container_bg = "#181818"
theme.mm_container_margin = 10
theme.mm_spacing = 10

-- Control widget style
theme.mm_control_spacing = 10
theme.mm_control_bg = "#181818"
theme.mm_control_button_size = 56
theme.mm_control_button_color = "#282828"
theme.mm_control_button_color_pressed = "#207bb8"
theme.mm_control_button_color_disabled = "#383838"
theme.mm_control_icon_color = "#ffffff"
theme.mm_control_icon_disabled_color = "#808080"

-- Sound widget style
theme.mm_sound_slider_bg = "#101010"
theme.mm_sound_slider_color = "#207bb8"
theme.mm_sound_slider_color_muted = "#606060"
theme.mm_sound_icon_color = "#ffffff"

-- Power widget style
theme.mm_powermenu_icon_colors = {
    "#ffffff",
    "#ffffff",
    "#ffffff",
    "#ffffff",
    "#ffffff"
}
theme.mm_powermenu_bg = "#181818"
theme.mm_powermenu_bg_hover = "#202020"

-- Wifi widget style
theme.mm_wifi_bg = "#282828"
theme.mm_wifi_border = "#181818"
theme.mm_wifi_header = "#181818"
theme.mm_wifi_close_hover_bg = "#202020"
theme.mm_wifi_entry_bg_hover = "#303030"
theme.mm_wifi_entry_bg_connected = "#000000"
theme.mm_wifi_entry_bg_connected_hover = "#ffffff"

-- Profile widget style
theme.mm_profile_username_color = "#ffffff"
theme.mm_profile_hostname_color = "#aaaaaa"

-- Places widget style
theme.mm_places_header_color = "#ffffff"
theme.mm_places_text_colors = {
    "#ffffff"
}
theme.mm_places_entry_color = "#181818"
theme.mm_places_entry_hover_color = "#202020"

-- Notification style
theme.notification_height = 120
theme.notification_width = 360
theme.notification_margin = 10
theme.notification_icon_size = theme.notification_height - theme.notification_margin
theme.notification_border_width = 1
theme.notification_border_color = "#383838"
theme.notification_bg = "#282828"
theme.notification_fg = "#aaaaaa"

-- Define the image to load
--theme.titlebar_close_button_normal = themes_path.."default/titlebar/close_normal.png"
--theme.titlebar_close_button_focus  = themes_path.."default/titlebar/close_focus.png"
--
--theme.titlebar_minimize_button_normal = themes_path.."default/titlebar/minimize_normal.png"
--theme.titlebar_minimize_button_focus  = themes_path.."default/titlebar/minimize_focus.png"
--
--theme.titlebar_ontop_button_normal_inactive = themes_path.."default/titlebar/ontop_normal_inactive.png"
--theme.titlebar_ontop_button_focus_inactive  = themes_path.."default/titlebar/ontop_focus_inactive.png"
--theme.titlebar_ontop_button_normal_active = themes_path.."default/titlebar/ontop_normal_active.png"
--theme.titlebar_ontop_button_focus_active  = themes_path.."default/titlebar/ontop_focus_active.png"
--
--theme.titlebar_sticky_button_normal_inactive = themes_path.."default/titlebar/sticky_normal_inactive.png"
--theme.titlebar_sticky_button_focus_inactive  = themes_path.."default/titlebar/sticky_focus_inactive.png"
--theme.titlebar_sticky_button_normal_active = themes_path.."default/titlebar/sticky_normal_active.png"
--theme.titlebar_sticky_button_focus_active  = themes_path.."default/titlebar/sticky_focus_active.png"
--
--theme.titlebar_floating_button_normal_inactive = themes_path.."default/titlebar/floating_normal_inactive.png"
--theme.titlebar_floating_button_focus_inactive  = themes_path.."default/titlebar/floating_focus_inactive.png"
--theme.titlebar_floating_button_normal_active = themes_path.."default/titlebar/floating_normal_active.png"
--theme.titlebar_floating_button_focus_active  = themes_path.."default/titlebar/floating_focus_active.png"
--
--theme.titlebar_maximized_button_normal_inactive = themes_path.."default/titlebar/maximized_normal_inactive.png"
--theme.titlebar_maximized_button_focus_inactive  = themes_path.."default/titlebar/maximized_focus_inactive.png"
--theme.titlebar_maximized_button_normal_active = themes_path.."default/titlebar/maximized_normal_active.png"
--theme.titlebar_maximized_button_focus_active  = themes_path.."default/titlebar/maximized_focus_active.png"

-- Pictures
theme.wallpaper = config.themePath.."/wallpaper.jpg"
theme.profile_picture = config.themePath.."/profile.png"

-- You can use your own layout icons like this:
-- theme.layout_fairh = themes_path.."default/layouts/fairhw.png"
-- theme.layout_fairv = themes_path.."default/layouts/fairvw.png"
-- theme.layout_floating  = themes_path.."default/layouts/floatingw.png"
-- theme.layout_magnifier = themes_path.."default/layouts/magnifierw.png"
-- theme.layout_max = themes_path.."default/layouts/maxw.png"
-- theme.layout_fullscreen = themes_path.."default/layouts/fullscreenw.png"
-- theme.layout_tilebottom = themes_path.."default/layouts/tilebottomw.png"
-- theme.layout_tileleft   = themes_path.."default/layouts/tileleftw.png"
-- theme.layout_tile = themes_path.."default/layouts/tilew.png"
-- theme.layout_tiletop = themes_path.."default/layouts/tiletopw.png"
-- theme.layout_spiral  = themes_path.."default/layouts/spiralw.png"
-- theme.layout_dwindle = themes_path.."default/layouts/dwindlew.png"
-- theme.layout_cornernw = themes_path.."default/layouts/cornernww.png"
-- theme.layout_cornerne = themes_path.."default/layouts/cornernew.png"
-- theme.layout_cornersw = themes_path.."default/layouts/cornersww.png"
-- theme.layout_cornerse = themes_path.."default/layouts/cornersew.png"

-- Icons
theme.getIcon = function (name, color)
    local path = config.iconPath.."/"..name..".svg"

    if not color then
        return path
    else
        return gears.color.recolor_image(path, color)
    end
end

theme.mainMenuIcon = theme.getIcon("arch")
theme.leftTriangle = theme.getIcon("triangle-left-h")
theme.rightTriangle = theme.getIcon("triangle-right-h")

-- Define the icon theme for application icons. If not set then the icons
-- from /usr/share/icons and /usr/share/icons/hicolor will be used.
theme.icon_theme = nil

return theme
