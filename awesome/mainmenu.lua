local config    = require("config")
local utility   = require("utility")
local controlWidget = require("widgets.control")
local soundWidget = require("widgets.sound")
local profileWidget = require("widgets.profile")
local powermenuWidget = require("widgets.powermenu")
local wifiPopup = require("widgets.wifipopup")
local placesWidget = require("widgets.places")
local brightnessWidget = require("widgets.brightness")

local networkDev = require("devices.network")

local module = {}

local function widgetContainer(widget)
    local layout = Wibox.widget {
        widget = Wibox.container.background,
        bg = Theme.mm_container_bg,
        shape = Gears.shape.rounded_rect,

        {
            widget = Wibox.container.margin,
            top = Theme.mm_container_margin,
            bottom = Theme.mm_container_margin,
            right = Theme.mm_container_margin,
            left = Theme.mm_container_margin,

            widget
        }
    }

    return layout
end

local function refreshButtons()
    networkDev.refreshButtons(module.control.controlButtons.wifi, module.control.controlButtons.network)

    -- Refresh sound buttons
    Awful.spawn.easy_async("amixer -D pulse get Master", function (stdout, stderr, code, reason)
        local percent, state = stdout:match("Playback%s+%d+%s+%[(%d+)%%%]%s+%[(%w+)%]")
        module.sound.speakerVolume = percent / 100
        if state == "on" then
            module.sound.speakerState = true
        else
            module.sound.speakerState = false
        end
        module.sound.updateBars()
    end)

    Awful.spawn.easy_async("amixer -D pulse get Capture", function (stdout, stderr, code, reason)
        local percent, state = stdout:match("Capture%s+%d+%s+%[(%d+)%%%]%s+%[(%w+)%]")
        module.sound.microphoneVolume = percent / 100
        if state == "on" then
            module.sound.microphoneState = true
        else
            module.sound.microphoneState = false
        end
        module.sound.updateBars()
    end)
end

local buttonRefreshTimer = Gears.timer {
    timeout = 0.5,
    autostart = false,
    single_shot = true,
    callback = refreshButtons
}

local function openLocation(location)
    Awful.spawn("dolphin "..location)
    module.hideMenu()
end

local function makeWidget()
    if module.menuGrid == nil then
        -- Make button control widget
        module.control = controlWidget.make()

        -- Make volume adjustment widget
        module.sound = soundWidget.make(function (info)
            local speakerButton = module.control.controlButtons.speaker
            speakerButton.setArg("enabled", true)
            speakerButton.setArg("state", info[1].state)
            speakerButton.setArg("handler_value_changed", function (button, state)
                module.sound.setMute(1, not state)
            end)

            local microphoneButton = module.control.controlButtons.microphone
            microphoneButton.setArg("enabled", true)
            microphoneButton.setArg("state", info[1].state)
            microphoneButton.setArg("handler_value_changed", function (button, state)
                module.sound.setMute(2, not state)
            end)
        end)

        -- Make profile widget
        module.profile = profileWidget.make()

        -- Make power buttons widget
        module.powermenu = powermenuWidget.make(module.hideMenu)

        -- Make Wi-Fi network selector popup
        module.wifiPopup = wifiPopup.make(function (newConn)
            local wifiButton = module.control.controlButtons.wifi
            if newConn.connection == nil then
                --wifiButton.setArg("enabled", wifiButton.)
                wifiButton.setArg("state", false)
                wifiButton.stat = false
            else
                wifiButton.setArg("enabled", true)
                wifiButton.setArg("state", newConn.state)
                wifiButton.stat = newConn.state
                wifiButton.conn = newConn.connection
            end
        end)
        module.control.controlButtons.wifi.setArg("handler_press_right", function (button, state)
            module.wifiPopup.show()
        end)

        -- Make places widget
        module.places = placesWidget.make(openLocation)

        -- Make brightness widget
        module.brightness = brightnessWidget.make()

        -- Make module grid
        module.menuGrid = Wibox.widget {
            layout = Wibox.layout.grid,
            spacing = Theme.mm_spacing,
            forced_num_cols = 16,
            forced_num_rows = 8,
            expand = true,
            homogeneous = true
        }

        -- Place widgets on the grid
        for name, conf in pairs(config.mainmenu_layout) do
            local widget = module[name]
            if conf.wrap then
                widget = widgetContainer(widget)
            end

            module.menuGrid:add_widget_at(widget, conf.y, conf.x, conf.height, conf.width)
        end
    end

    return module.menuGrid
end

local function makeKeyGrabber()
    if module.keyGrabber == nil then
        local keybinds = {
            { {}, "m", module.control.controlButtons.microphone.toggleState },
            { {}, "s", module.control.controlButtons.speaker.toggleState },
            { {}, "Escape", function ()
                local screen = Awful.screen.focused()
                screen:toggleMainMenu()
            end },
            { { config.modKey }, "m", function ()
                local screen = Awful.screen.focused()
                screen:toggleMainMenu()
            end }
        }

        -- Power Actions
        for i = 1, 5 do
            keybinds[#keybinds+1] = { { config.modKey }, "F"..tostring(i), powermenuWidget.buttons[i].func }
        end

        -- Places Actions
        for i = 1, 5 do
            keybinds[#keybinds+1] = { { }, tostring(i), function() openLocation(config.places[i].path) end }
        end

        module.keyGrabber = Awful.keygrabber {
            keybindings = keybinds
        }
    end

    return module.keyGrabber
end

local function getDimension(cellCount)
    return 64 * cellCount + 10 * (cellCount - 1)
end

local function toggleMainMenu(screen)
    if module.mainMenu.screen ~= screen then
        local oldScreen = module.mainMenu.screen
        local overlay = module.overlays[tostring(screen.index)]

        module.overlays[tostring(screen.index)] = nil
        module.overlays[tostring(oldScreen.index)] = overlay

        overlay.screen = oldScreen
        module.mainMenu = screen
    end

    if module.mainMenu.visible then
        module.mainMenu.visible = false
        module.keyGrabber:stop()
    else
        module.mainMenu.visible = true
        buttonRefreshTimer:start()
        --refreshButtons()
        module.keyGrabber:start()
    end
end

function module.hideMenu()
    if module.mainMenu.visible then
        module.mainMenu.visible = false
        module.keyGrabber:stop()
    end
end

function module.make(screen)
    if not module.mainMenu then
        module.mainMenu = Awful.popup({
            widget = Wibox.widget {
                widget = Wibox.container.place,
                {
                    widget = Wibox.container.constraint,
                    strategy = "exact",
                    width = getDimension(16),
                    height = getDimension(8),

                    makeWidget()
                }
            },

            screen = screen,

            ontop = true,
            placement = Awful.placement.maximize,

            bg = "#00000080",
            visible = false
        })

        module.overlays = {}

        makeKeyGrabber()

        module.mainMenu:buttons(Gears.table.join(
            Awful.button({}, 1, nil)
        ))

        module.mainMenu.widget:connect_signal("button::press", function (_, x, y, button, mod)
            local widgets = module.mainMenu:find_widgets(x, y)
            if #widgets <= 4 then
                -- We have <= 4 widgets under our mouse, we are not on any element of the main menu
                -- These 4 widgets are only the invisible layout elements, therefor we hide the
                -- menu when we click on them
                module.hideMenu()
            end
        end)
    elseif not module.overlays[tostring(screen.index)] then
        module.overlays[tostring(screen.index)] = Awful.popup({
            widget = nil,

            screen = screen,

            ontop = true,
            placement = Awful.placement.maximize,

            bg = "#00000080",
            visible = false
        })

        module.overlays[tostring(screen.index)]:buttons(Gears.table.join(
            Awful.button({}, 1, module.hideMenu)
        ))
    end

    screen.toggleMainMenu = toggleMainMenu
end

return module
