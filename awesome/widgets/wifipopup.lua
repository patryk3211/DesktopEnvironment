local utility = require "utility"
local module = {}

local function makeText(text)
    return Wibox.widget {
        widget = Wibox.container.margin,
        top = 5,
        bottom = 5,
        left = 8,
        right = 8,
        {
            widget = Wibox.widget.textbox,
            text = text
        }
    }
end

function module.make(connectionChangedCallback)
    local infoScanText = Wibox.widget {
        widget = Wibox.container.margin,
        right = 8,
        left = 8,
        top = 4,

        {
            widget = Wibox.widget.textbox,
            text = "Scanning for wireless networks..."
        }
    }

    local widget = Awful.popup({
        widget = Wibox.widget {
            widget = Wibox.container.constraint,
            strategy = "min",
            height = 200,
            forced_width = 360,
            {
                layout = Wibox.layout.fixed.vertical,
                spacing = 0,

                {
                    id = "header",
                    widget = Wibox.container.background,
                    forced_height = 28,
                    bg = Theme.mm_wifi_header,
                    {
                        layout = Wibox.layout.align.horizontal,
                        {
                            widget = Wibox.container.margin,
                            top = 5,
                            left = 8,
                            right = 8,
                            bottom = 2,

                            {
                                widget = Wibox.widget.textbox,
                                text = "Wireless Networks"
                            }
                        },
                        nil,
                        {
                            id = "close_button",
                            widget = Wibox.container.background,
                            {
                                widget = Wibox.container.margin,
                                top = 5,
                                bottom = 5,
                                right = 8,
                                left = 8,

                                {
                                    widget = Wibox.widget.imagebox,
                                    image = Theme.getIcon("close", "#ffffff")
                                }
                            }
                        }
                    }
                }
            }
        },

        placement = Awful.placement.under_mouse,
        ontop = true,

        border_color = Theme.mm_wifi_border,
        border_width = 1,

        bg = Theme.mm_wifi_bg,
        visible = false
    })

    local closeButton = widget.widget:get_children_by_id("close_button")[1]
    utility.smoothHoverColor(closeButton, Theme.mm_wifi_header, Theme.mm_wifi_close_hover_bg)

    local layout = widget.widget.children[1]
    local header = widget.widget:get_children_by_id("header")[1]

    local grabbed = false
    local mX = 0
    local mY = 0

    header:buttons(Gears.table.join(
        Awful.button({}, 1, function ()
            grabbed = true
        end, function ()
            grabbed = false
        end)
    ))

    header:connect_signal("button::press", function (_, x, y, button)
        if button ~= 1 then
            return
        end
        mX = x
        mY = y
    end)

    widget:connect_signal("mouse::move", function (_, x, y)
        if grabbed then
            local dX = x - mX
            local dY = y - mY
            widget.x = widget.x + dX
            widget.y = widget.y + dY
        end
    end)

    local connected = nil
    widget.show = function (screen, noScan)
        for i = 2, #layout.children do
            layout:remove(2)
        end

        local suffix = ""
        if noScan then
            suffix = " --rescan no"
        else
            layout:add(infoScanText)
        end

        Awful.spawn.easy_async("nmcli -g ssid,chan,security,signal,in-use dev wifi list"..suffix, function (stdout, stderr, reason, code)
            widget.placement = nil
            if not noScan then
                layout:remove(2)
            end
            local added = false

            for ssid, channel, security, signal, isused in stdout:gmatch("([%w _%-]+):(%d+):(%w*):(%d+):(%*?)") do
                if security == "" then
                    security = "None"
                end

                local entry = Wibox.widget {
                    widget = Wibox.container.background,
                    bg = Theme.mm_wifi_bg,

                    {
                        widget = Wibox.container.margin,
                        left = 8,
                        right = 8,
                        top = 4,
                        bottom = 4,
                        {
                            widget = Wibox.container.constraint,
                            strategy = "exact",
                            height = 28,
                            {
                                id = "elements",
                                layout = Wibox.layout.ratio.horizontal,
                                spacing = 5,
                                {
                                    widget = Wibox.container.radialprogressbar,
                                    min_value = 0,
                                    max_value = 100,
                                    value = tonumber(signal),

                                    border_color = "#181818",
                                    color = "#606060",
                                    border_width = 5,

                                    {
                                        widget = Wibox.widget.textbox,
                                        text = signal.."%",
                                        font = "Hack Nerd Regular 8",
                                        align = "center"
                                    }
                                },
                                {
                                    widget = Wibox.widget.textbox,
                                    text = ssid,
                                    ellipsize = "end",
                                    wrap = "char"
                                },
                                {
                                    widget = Wibox.widget.textbox,
                                    text = channel,
                                    align = "center"
                                },
                                {
                                    widget = Wibox.widget.textbox,
                                    text = security
                                }
                            }
                        }
                    }
                }

                entry.data = {
                    ssid = ssid
                }

                if isused == "*" then
                    entry.connected = true
                    connected = entry
                end

                utility.smoothHoverColorCallback(entry, function ()
                    if not entry.connected then
                        return Theme.mm_wifi_bg
                    else
                        return Theme.mm_wifi_entry_bg_connected
                    end
                end, function ()
                    if not entry.connected then
                        return Theme.mm_wifi_entry_bg_hover
                    else
                        return Theme.mm_wifi_entry_bg_connected_hover
                    end
                end)

                local textLayout = entry:get_children_by_id("elements")[1]
                textLayout:set_ratio(1, 0.175)
                textLayout:set_ratio(2, 0.60)
                textLayout:set_ratio(3, 0.05)
                textLayout:set_ratio(4, 0.175)

                entry:buttons(Gears.table.join(
                    Awful.button({}, 1, function ()
                        -- Connect/Disconnect
                        if entry.connected then
                            connected = nil
                            entry.connected = false

                            Awful.spawn.easy_async("nmcli conn down '"..entry.data.ssid.."'", function ()
                                for i = 2, #layout.children do
                                    layout:remove(2)
                                end
                                layout:add(makeText("Disconnected from "..entry.data.ssid))
                                if connectionChangedCallback then
                                    connectionChangedCallback({ status = false })
                                end

                                Gears.timer {
                                    timeout = 2,
                                    autostart = true,
                                    single_shot = true,
                                    callback = function ()
                                        widget.show(screen, true)
                                    end
                                }
                            end)
                        else
                            -- TODO: Implement password support
                            for i = 2, #layout.children do
                                layout:remove(2)
                            end
                            layout:add(makeText("Connecting to "..entry.data.ssid.."..."))
                            Awful.spawn.easy_async("nmcli dev wifi connect '"..entry.data.ssid.."'", function (stdout)
                                layout:remove(2)
                                if stdout:match("Error") then
                                    layout:add(makeText(stdout))
                                    Gears.timer {
                                        timeout = 2,
                                        autostart = true,
                                        single_shot = true,
                                        callback = function ()
                                            widget.show(screen, true)
                                        end
                                    }
                                else
                                    if connected ~= nil then
                                        connected.connected = false
                                        Awful.spawn("nmcli conn delete '"..connected.data.ssid.."'")
                                    end
                                    entry.connected = true
                                    connected = entry

                                    layout:add(makeText("Succesfully connected to "..entry.data.ssid))
                                    if connectionChangedCallback then
                                        connectionChangedCallback({ connection = entry.data.ssid, status = false })
                                    end
                                    Gears.timer {
                                        timeout = 2,
                                        autostart = true,
                                        single_shot = true,
                                        callback = function ()
                                            widget.show(screen, true)
                                        end
                                    }
                                end
                            end)
                        end
                    end)
                ))

                layout:add(entry)
                added = true
            end

            if not added then
                layout:add(makeText("No networks found"))
            end
        end)

        if not widget.visible then
            widget.screen = screen
            widget.visible = true
        else
            widget.placement = nil
        end
    end

    widget.hide = function ()
        widget.visible = false
        widget.placement = Awful.placement.under_mouse
        grabbed = false
    end

    closeButton:buttons(Gears.table.join(
        Awful.button({}, 1, widget.hide)
    ))

    return widget
end

return module
