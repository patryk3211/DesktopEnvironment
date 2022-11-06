pcall(require, "luarocks.loader")
local utility = require("utility")

Gears = require("gears")
Awful = require("awful")
require("awful.autofocus")

Wibox = require("wibox")
Theme = require("beautiful")

local naughty = require("naughty")
local menubar = require("menubar")
local hotkeys_popup = require("awful.hotkeys_popup")
require("awful.hotkeys_popup.keys")

local posix = require("posix.stdlib")

local screen = require("screen")
local config = require("config")
local keys = require("keybind")
local rules = require("rules")
local signals = require("signals")


-- Register some error handlers
if awesome.startup_errors then
    naughty.notify({
        preset = naughty.config.presets.critical,
        title = "An error has occured in the awesome config",
        text = awesome.startup_errors
    })
end

do
    local inError = false
    awesome.connect_signal("debug::error", function(err)
        if inError then
            return
        end

        inError = true
        naughty.notify({
            preset = naughty.config.presets.critical,
            title = "An error has occured in the window manager",
            text = tostring(err)
        })
        inError = false
    end)
end

-- Load theme
Theme.init(config.themePath.."/theme.lua")

-- Initilize some utility stuff
local initializer = coroutine.create(utility.dbus.init)
coroutine.resume(initializer)

require("devices.battery").init()

-- Enabled layouts
Awful.layout.layouts = {
    Awful.layout.suit.fair
}

menubar.utils.terminal = config.terminal
client.maximized = false

posix.setenv("QT_QPA_PLATFORMTHEME", "qt5ct")
posix.setenv("PATH", os.getenv("PATH")..":/home/patryk/.cargo/bin:/var/lib/snapd/snap/bin:/home/patryk/.local/bin")

Awful.spawn("setxkbmap -layout \"pl,us\"")
Awful.spawn("wmname LG3D")
utility.spawnOne("picom")
utility.spawnOne("xss-lock dm-tool lock")

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

-- Make screens and bind stuff
Awful.screen.connect_for_each_screen(screen.makeScreen)
keys.bindGlobal()
rules.makeRules()

signals.connect()

for _, cb in ipairs(utility.postInit) do
    cb()
end
utility.postInit = nil
