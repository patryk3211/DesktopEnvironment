pcall(require, "luarocks.loader")

Gears = require("gears")
Awful = require("awful")
require("awful.autofocus")

Wibox = require("wibox")
Theme = require("beautiful")

local naughty = require("naughty")
local menubar = require("menubar")

local posix = require("posix.stdlib")

local config = require("config")
local utility = require("utility")
local screenConf = require("screen")
local keysConf = require("keybind")


-- Register some error handlers
naughty.connect_signal("request::display_error", function(message, startup)
    naughty.notification {
        urgency = "critical",
        title   = "An error has occured in the awesome config"..(startup and " during startup!" or "!"),
        message = message
    }
end)

-- Load theme
Theme.init(config.themePath.."/theme.lua")

-- Set global keybinds
keysConf.bindGlobal()
-- Apply rules
require("rules")

-- Initialize some modules
utility.dbus.init()
require("devices.battery").init()

-- Enable default layouts
tag.connect_signal("request::default_layouts", function ()
    Awful.layout.append_default_layouts({
        Awful.layout.suit.fair
    })
end)

screen.connect_signal("request::wallpaper", screenConf.setWallpaper)
screen.connect_signal("request::desktop_decoration", screenConf.makeScreen)

-- Connect default signals
require("signals")

-- Setup the environment and startup the default applications
posix.setenv("QT_QPA_PLATFORMTHEME", "qt5ct")
posix.setenv("PATH", os.getenv("PATH")..":/home/patryk/.cargo/bin:/var/lib/snapd/snap/bin:/home/patryk/.local/bin")

Awful.spawn("setxkbmap -layout \"pl,us\"")
Awful.spawn("wmname LD3D")
utility.spawnOne("picom")
utility.spawnOne("xss-lock dm-tool lock")

-- Setup garbage collector variables
collectgarbage("setstepmul", 400)

Gears.timer {
    timeout = 30,
    autostart = true,
    single_shot = false,
    callback = function ()
        collectgarbage("collect")
        collectgarbage("collect")
    end
}

-- Post-init callbacks
for _, cb in ipairs(utility.postInit) do cb() end
utility.postInit = nil
