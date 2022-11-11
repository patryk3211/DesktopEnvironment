local config = require("config")
local utility = require("utility")

local module = {}

local function mediaPlayPause()
    utility.dbus.getTarget("org.mpris.MediaPlayer2", function (target)
        utility.dbus.callMethod({
            destination = target,
            object = "/org/mpris/MediaPlayer2",
            interface = "org.mpris.MediaPlayer2.Player",
            func = "PlayPause"
        })
    end)
end

function module.bindGlobal()
    Awful.keyboard.append_global_keybindings({
        Awful.key({ config.modKey }, "n", function ()
            local screen = Awful.screen.focused()
            screen.prompt()
        end, { description = "Spawn a new process from prompt" }),
        Awful.key({ config.modKey, "Shift" }, "r", function ()
            awesome.restart()
        end,
            { description = "Restart awesome" }),
        Awful.key({ }, "XF86AudioPlay", mediaPlayPause),
        Awful.key({ config.modKey }, " ", function ()
            Awful.tag.viewnone()
        end, { description = "Play/pause media" }),
        Awful.key({ config.modKey }, "m", function ()
            local screen = Awful.screen.focused()
            screen:toggleMainMenu()
        end, { description = "Toggle main menu" }),
        Awful.key({ config.modKey }, "a", function ()
            Awful.client.focus.byidx(-1)
        end, { description = "Move focus to previous client" }),
        Awful.key({ config.modKey }, "d", function ()
            Awful.client.focus.byidx(1)
        end, { description = "Move focus to next client" }),
        Awful.key({ config.modKey, "Shift" }, "a", function ()
            Awful.client.swap.byidx(-1)
        end, { description = "Swap client with previous" }),
        Awful.key({ config.modKey, "Shift" }, "d", function ()
            Awful.client.swap.byidx(1)
        end, { description = "Swap client with next" }),
        Awful.key({ config.modKey }, "w", function ()
            Awful.tag.incmwfact(0.05)
        end, { description = "Increase master width factor" }),
        Awful.key({ config.modKey }, "s", function ()
            Awful.tag.incmwfact(-0.05)
        end, { description = "Descrease master width factor" }),
        Awful.key({ }, "Print", function ()
            Awful.spawn("spectacle")
        end, { description = "Take a screenshot "})
    })

    Awful.keyboard.append_global_keybindings({
        Awful.key {
            modifiers = { config.modKey },
            keygroup = "numrow",
            description = "Switch to tag",
            on_press = function (index)
                local screen = Awful.screen.focused()
                local tag = screen.tags[index]
                if tag then tag:view_only() end
            end
        },
        Awful.key {
            modifiers = { config.modKey, "Shift" },
            keygroup = "numrow",
            description = "Move client in focus to tag",
            on_press = function (index)
                local screen = Awful.screen.focused()
                local tag = screen.tags[index]
                if tag and client.focus then
                    client.focus:move_to_tag(tag)
                end
            end
        },
        Awful.key {
            modifiers = { config.modKey, "Control" },
            keygroup = "numrow",
            description = "Toggle visibility of tag",
            on_press = function (index)
                local screen = Awful.screen.focused()
                local tag = screen.tags[index]
                if tag then Awful.tag.viewtoggle(tag) end
            end
        },
        Awful.key {
            modifiers = { config.modKey, "Shift", "Control" },
            keygroup = "numrow",
            description = "Move all visible clients to tag",
            on_press = function (index)
                local screen = Awful.screen.focused()
                local tag = screen.tags[index]
                for _, c in ipairs(screen.all_clients) do
                    if c:isvisible() then
                        c:move_to_tag(tag)
                    end
                end
            end
        },
        Awful.key {
            modifiers = { config.modKey, "Mod1" },
            keygroup = "numrow",
            description = "Execute command of tag",
            on_press = function (index)
                local screen = Awful.screen.focused()
                local tag = screen.tags[index]
                if tag then
                    local configEntry = config.groups[tag.index]
                    local exec = configEntry.program
                    if exec then
                        if configEntry.spawnOne then
                            utility.spawnOne(exec)
                        else
                            Awful.spawn(exec)
                        end
                    end
                end
            end
        }
    })

    client.connect_signal("request::default_mousebindings", function ()
        Awful.mouse.append_client_mousebindings({
            Awful.button({}, 1, function (client)
                client:emit_signal("request::activate", "mouse_click", { raise = true })
            end),
            Awful.button({}, 3, function (client)
                client:emit_signal("request::activate", "mouse_click", { raise = true })
            end),
            Awful.button({ config.modKey }, 1, function (client)
                client:emit_signal("request::activate", "mouse_click", { raise = true })
                Awful.mouse.client.move(client)
            end),
            Awful.button({ config.modKey }, 3, function (client)
                client:emit_signal("request::activate", "mouse_click", { raise = true })
                Awful.mouse.client.resize(client)
            end)
        })
    end)

    client.connect_signal("request::default_keybindings", function ()
        Awful.keyboard.append_client_keybindings({
            Awful.key({ config.modKey }, "q", function (client)
                client:kill()
            end, { description = "Close the current window" }),
            Awful.key({ config.modKey }, "g", function (client)
                client.maximized = not client.maximized
                client:raise()
            end, { description = "Toggle maximize of the current window" }),
            Awful.key({ config.modKey }, "f", function (client)
                client.floating  = not client.floating
                client:raise()
            end, { description = "Toggle floating of the current window" })
        })
    end)
end

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
