local config = require("config")
local utility = require("utility")

local module = {}

local function mediaPlayPause()
    utility.getDbusTarget("org.mpris.MediaPlayer2", function (target)
        Awful.spawn("dbus-send --print-reply --dest="..target.." /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player.PlayPause")
    end)
end

function module.bindGlobal()
    local globalKeys = Gears.table.join(
        Awful.key({ config.modKey }, "n", function ()
            local screen = Awful.screen.focused()
            screen.prompt()
        end, { description = "Spawn a new process from prompt" }),
        Awful.key({ config.modKey, "Shift" }, "r", function ()
            Awful.spawn("killall picom")
            awesome.restart()
        end,
            { description = "Restart awesome" }),
        Awful.key({ }, "XF86AudioPlay", mediaPlayPause),
        Awful.key({ config.modKey }, " ", function ()
            Awful.tag.viewnone()
        end),
        Awful.key({ config.modKey }, "m", function ()
            local screen = Awful.screen.focused()
            screen:toggleMainMenu()
        end)
    )

    local keyBindCount = math.min(config.groupCount, 9)
    for i = 1, keyBindCount do
        globalKeys = Gears.table.join(globalKeys,
            Awful.key({ config.modKey }, tostring(i), function ()
                local screen = Awful.screen.focused()
                local tag = screen.tags[i]
                if tag then
                    tag:view_only()
                end
            end, { description = "Switch to tag #"..i }),
            Awful.key({ config.modKey, "Control" }, tostring(i), function ()
                local screen = Awful.screen.focused()
                local tag = screen.tags[i]
                if tag then
                    Awful.tag.viewtoggle(tag)
                end
            end),
            Awful.key({ config.modKey, "Shift" }, tostring(i), function ()
                local screen = Awful.screen.focused()
                local tag = screen.tags[i]
                if tag and client.focus then
                    client.focus:move_to_tag(tag)
                end
            end)
        )
    end

    root.keys(globalKeys)
end

module.clientKeys = Gears.table.join(
    Awful.key({ config.modKey }, "q", function (client)
        client:kill()
    end, { description = "Close the current window" }),
    Awful.key({ config.modKey }, "m", function (client)
        client.maximized = not client.maximized
        client:raise()
    end)
)

module.clientButtons = Gears.table.join(
    Awful.button({}, 1, function (client)
        client:emit_signal("request::activate", "mouse_click", { raise = true })
    end),
    Awful.button({}, 3, function (client)
        client:emit_signal("request::activate", "mouse_click", { raise = true })
    end)
)

module.taglistButtons = Gears.table.join(
    Awful.button({}, 1, function (tag) tag:view_only() end),
    Awful.button({}, 2, function (tag) -- Spawn a task defined in config for this tag
        local configEntry = config.groups[tag.index]
        local exec = configEntry.program
        if exec then
            if configEntry.spawnOne then
                utility.spawnOne(exec)
            else
                Awful.spawn(exec)
            end
        end
    end),
    Awful.button({ "Control" }, 1, function (tag)
        Awful.tag.viewtoggle(tag)
    end),
    Awful.button({ config.modKey }, 1, function (tag)
        if client.focus then
            client.focus:move_to_tag(tag)
        end
    end)
)

return module
