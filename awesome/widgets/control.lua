local rubato = require("rubato")

local utility = require("utility")
local easing = require("easing")

local module = {}
local cache = nil

local function makeButton(args)
    local img = Wibox.widget.imagebox(Theme.getIcon(args.icon, Theme.mm_control_icon_color))

    local button = Wibox.widget {
        widget = Wibox.container.background,
        bg = Theme.mm_control_button_color,
        shape = Gears.shape.circle,

        forced_width = Theme.mm_control_button_size,
        forced_height = Theme.mm_control_button_size,

        {
            widget = Wibox.container.margin,
            top = Theme.mm_control_button_size * 0.3,
            bottom = Theme.mm_control_button_size * 0.3,
            right = Theme.mm_control_button_size * 0.3,
            left = Theme.mm_control_button_size * 0.3,

            img
        }
    }

    if args.enabled == nil then
        args.enabled = true
    end

    if args.state == nil then
        args.state = false
    end

    local colorChangeTimer = rubato.timed {
        duration = 0.15,
        intro = 0,
        easing = easing.easeinout
    }

    colorChangeTimer:subscribe(function (pos)
        if pos ~= pos then
            colorChangeTimer.pos = 0
            pos = 0
        end

        if args.enabled then
            button.bg = utility.mixColorHtml(Theme.mm_control_button_color, Theme.mm_control_button_color_pressed, pos)
            img.image = Theme.getIcon(args.icon, Theme.mm_control_icon_color)
        else
            button.bg = Theme.mm_control_button_color_disabled
            img.image = Theme.getIcon(args.icon, Theme.mm_control_icon_disabled_color)
        end
    end)

    if args.state then
        colorChangeTimer.target = 1
    end

    button:buttons(Gears.table.join(
        Awful.button({}, 1, function ()
            if args.enabled then
                -- Toggle the button
                args.state = not args.state
                if args.state then
                    colorChangeTimer.target = 1
                else
                    colorChangeTimer.target = 0
                end

                if args.handler_value_changed then
                    args.handler_value_changed(button, args.state)
                end
            end
        end),
        Awful.button({}, 3, function ()
            if args.handler_press_right then
                args.handler_press_right(button, args.state, args.enabled)
            end
        end)
    ))

    button.setArg = function (name, value)
        args[name] = value
        if name == "enabled" or name == "state" then
            if args.state then
                colorChangeTimer.target = 1
            else
                colorChangeTimer.target = 0
            end
            colorChangeTimer:fire()
        end
    end

    button.toggleState = function ()
        args.state = not args.state
        if args.state then
            colorChangeTimer.target = 1
        else
            colorChangeTimer.target = 0
        end
        if args.handler_value_changed then
            args.handler_value_changed(button, args.state)
        end
    end

    return button
end

local function toggleNetwork(button, state)
    button.setArg("state", not state)
    if not button.conn then
        return
    end

    local stateStr = "up"
    if not state then
        stateStr = "down"
    end

    Awful.spawn.easy_async("nmcli con "..stateStr.." '"..button.conn.."'", function ()
        button.setArg("state", state)
    end)
end

function module.make()
    if not cache then
        cache = {}
        cache.button_off = table.pack(Gears.color.parse_color(Theme.mm_control_button_color))
        cache.button_on = table.pack(Gears.color.parse_color(Theme.mm_control_button_color_pressed))
    end

    local buttons = {
        wifi = makeButton({ icon = "wifi", enabled = false, handler_value_changed = toggleNetwork }),
        network = makeButton({ icon = "network", enabled = false, handler_value_changed = toggleNetwork }),
        speaker = makeButton({ icon = "speaker", enabled = false }),
        microphone = makeButton({ icon = "microphone", enabled = false })
    }

    Awful.spawn.easy_async("nmcli -g connection,type,state d", function (stdout, stderr, reason, code)
        local wiredConnection, state = stdout:match("([%w%s]+):ethernet:(%w+)")
        if wiredConnection then
            buttons.network.conn = wiredConnection
            buttons.network.stat = false
            if state == "connected" then
                buttons.network.stat = true
            end
            buttons.network.setArg("enabled", true)
            buttons.network.setArg("state", buttons.network.stat)
        end

        local wirelessConnection, state = stdout:match("([%w_%- ]+):wifi:(%w+)")
        if wirelessConnection then
            if wirelessConnection == "" then
                buttons.wifi.conn = nil
                buttons.wifi.stat = false
                buttons.wifi.setArg("enabled", false)
                buttons.wifi.setArg("state", false)
            else
                buttons.wifi.conn = wirelessConnection
                buttons.wifi.stat = false
                if state == "connected" then
                    buttons.wifi.stat = true
                end
                buttons.wifi.setArg("enabled", true)
                buttons.wifi.setArg("state", buttons.wifi.stat)
            end
        else
            buttons.wifi.setArg("enabled", false)
        end
    end)

    local widget = Wibox.widget {
        layout = Wibox.layout.grid,

        homogeneous = true,
        spacing = Theme.mm_control_spacing,
        min_cols_size = Theme.mm_control_button_size,
        min_rows_size = Theme.mm_control_button_size,
        orientation = "horizontal",

        buttons.wifi,
        buttons.network,
        buttons.speaker,
        buttons.microphone
    }

    widget.controlButtons = buttons

    return widget
end

return module
