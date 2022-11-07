local config = require("config")
local utility = require("utility")
local keys = require("keybind")
local mainmenu = require("mainmenu")

local calendar = require("widgets.calendar")
local usage = require("widgets.usage")
local battery = require("widgets.battery")

local module = {}



local function makeSystray()
    return Wibox.widget {
        widget = Wibox.container.margin,
        top = 2,
        bottom = 4,
        right = 6,
        left = 6,
        {
            layout = Wibox.layout.fixed.horizontal,
            {
                widget = Wibox.widget.imagebox,
                image = Theme.getIcon("triangle-left-h", Theme.bg_systray),
            },
            {
                widget = Wibox.container.background,
                bg = Theme.bg_systray,
                {
                    widget = Wibox.container.margin,
                    top = 4,
                    bottom = 4,
                    left = 4,
                    right = 4,
                    {
                        widget = Wibox.widget.systray
                    }
                }
            },
            {
                widget = Wibox.widget.imagebox,
                image = Theme.getIcon("triangle-right-h", Theme.bg_systray)
            }
        }
    }
end



local infoBar = nil
local function makeInfoBar()
    -- Make only one info bar for all screens
    if not infoBar then
        infoBar = Wibox.layout.fixed.horizontal()
        infoBar:add(makeSystray())

        local first = true

        local function addSegment(segment, bg, fg)
            if not first then
                local lastSegment = infoBar.children[#infoBar.children]
                lastSegment.children[1]:add(Wibox.widget.imagebox(Theme.getIcon(Theme.leftTriangle, bg)))
            else
                infoBar:add(Wibox.widget.imagebox(Theme.getIcon(Theme.leftTriangle, bg)))
                first = false
            end
            infoBar:add(Wibox.widget {
                widget = Wibox.container.background,
                bg = bg,
                fg = fg,
                segment
            })
        end

        addSegment(Wibox.layout.fixed.horizontal(usage.make()), Theme.info_bg, Theme.info_fg)

        if battery.present() then
            addSegment(battery.make(), Theme.battery_bar_bg, Theme.battery_bar_fg)
        end

        addSegment(Wibox.layout.fixed.horizontal(calendar.make()), Theme.clock_bg, Theme.clock_fg)
    end
    return infoBar
end



local function makeTopBar(screen)
    local menuIcon = Wibox.container.background(Wibox.container.margin(Wibox.widget.imagebox(Theme.mainMenuIcon), 8, 8, 2, 2))
    menuIcon:buttons(Gears.table.join(
        Awful.button({}, 1, function ()
            screen:toggleMainMenu()
        end)
    ))
    utility.smoothHoverColor(menuIcon, Theme.bg_normal, "#303030")

    screen.topbar = Awful.wibar({ position = "top", screen = screen, height = 28 })
    screen.topbar:setup({
        layout = Wibox.layout.align.horizontal,
        { -- Left
            layout = Wibox.layout.fixed.horizontal,
            Wibox.container.margin(menuIcon, 0, 16, 0, 0),
            {
                layout = Wibox.layout.fixed.horizontal,
                Wibox.widget.imagebox(Theme.getIcon(Theme.leftTriangle, Theme.taglist_bg)),
                Wibox.container.margin(screen.taglist, 8, 8, 0, 0, Theme.taglist_bg),
                Wibox.widget.imagebox(Theme.getIcon(Theme.rightTriangle, Theme.taglist_bg))
            }
        },
        nil, -- Middle
        makeInfoBar() -- Right
    })
end



function module.makeScreen(screen)
    for i, value in ipairs(config.groups) do
        Awful.tag.add(value.groupName, {
            layout = Awful.layout.layouts[1],
            screen = screen,
            index = i
        })
    end

    -- Create the tag list
    screen.taglist = Awful.widget.taglist {
        screen = screen,
        filter  = function (t)
            local hide = config.groups[t.index].hideEmpty
            if not hide then
                return true
            end

            return t.selected or #t:clients() ~= 0
        end,
        buttons = keys.taglistButtons,

        widget_template = {
            {
                id = "text_role",
                widget = Wibox.widget.textbox,
                forced_width = 48,
                align = "center",
                valign = "center"
            },
            id = "background_role",
            widget = Wibox.container.background
        }
    }

    -- Make the top bar
    makeTopBar(screen)

    -- Make the prompt popup
    screen.prompt = function ()
        Awful.spawn("rofi -show drun") -- -run-list-command 'cat /home/patryk/.config/awesome/additional_targets'
    end

    mainmenu.make(screen)

    -- View tag 1 by default
    screen.tags[1]:view_only()
end

function module.setWallpaper(screen)
    Awful.wallpaper {
        screen = screen,
        widget = {
            {
                widget = Wibox.widget.imagebox,
                upscale = true,
                downscale = true,
                image = Theme.wallpaper
            },

            widget = Wibox.container.tile,
            valign = "center",
            halign = "center",
            tiled = true
        }
    }
end

--utility.addPostInitCallback(function ()
--    config = nil
--    keys = nil
--    mainmenu = nil
--    calendar = nil
--    usage = nil
--    battery = nil
--end)

return module
