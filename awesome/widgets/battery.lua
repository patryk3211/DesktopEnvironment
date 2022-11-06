local batteryDev = require("devices.battery")
local utility    = require("utility")

local module = {}

function module.present()
    return batteryDev.exists()
end

function module.make()
    local icon = Wibox.widget.imagebox(Theme.getIcon(Theme.battery_icon_unknown, Theme.battery_bar_fg))
    local text = Wibox.widget.textbox("????%")
    local fill = Wibox.widget.base.make_widget()
    fill.color = Gears.color("#ff0000")
    fill.fraction = 1

    icon._fit = icon.fit
    function icon:fit(context, width, height)
        local w, h = self:_fit(context, width, height)
        return math.floor(w), h
    end

    function fill:fit(context, width, height)
        return 0, height
    end

    function fill:draw(context, cr, width, height)
        local barHeight = math.floor(height * self.fraction)
        local barOffset = height - barHeight

        cr:rectangle(0, barOffset, width, barHeight)
        cr:set_source(self.color)
        cr:fill()
    end

    local widget = Wibox.widget {
        layout = Wibox.layout.fixed.horizontal,
        {
            widget = Wibox.container.margin,
            top = 4,
            bottom = 4,
            right = 7,
            left = 5,
            {
                layout = Wibox.layout.stack,
                {
                    widget = Wibox.container.margin,
                    top = 4,
                    bottom = 3,
                    left = 3,
                    right = 3,
                    fill
                },
                icon
            }
        },
        {
            widget = Wibox.container.constraint,
            width = 50,
            strategy = "exact",
            text
        }
    }

    if not batteryDev.exists() then
        -- Do not register the updator if battery is not present
        return widget
    end

    local tooltip = Awful.tooltip {
        objects = { widget },
        text = "Tooltip Text"
    }

    tooltip:connect_signal("property::visible", function ()
        local action = ""
        local timeLeft = batteryDev.getTimeToEmpty()

        if batteryDev.isCharging() then
            timeLeft = batteryDev.getTimeToCharge()
            action = " to full charge"
        end

        local minutes = math.floor(timeLeft / 60) % 60
        local minutesStr = "minutes"
        if minutes == 1 then
            minutesStr = "minute"
        end
        local hours = math.floor(timeLeft / 3600)

        if hours > 0 then
            local hourStr = "hours"
            if hours == 1 then
                hourStr = "hour"
            end

            tooltip.text = string.format("%d %s and %d %s left%s", hours, hourStr, minutes, minutesStr, action)
        else
            tooltip.text = string.format("%d %s left%s", minutes, minutesStr, action)
        end
    end)

    batteryDev.addUpdateCallback(function ()
        -- Update battery icon
        local fraction = batteryDev.getChargeFraction()

        local formatString = "????%%"
        if fraction == 1 then
            formatString = "100%%"
        elseif fraction >= 0.1 then
            formatString = "%.1f%%"
        else
            formatString = "%.2f%%"
        end

        text.text = string.format(formatString, fraction * 100)
        fill.fraction = fraction

        if batteryDev.isCharging() then
            fill.color = Gears.color(Theme.battery_charging_color)
        else
            if fraction <= Theme.battery_warning_level then
                fill.color = Gears.color(Theme.battery_warning_color)
            else
                fill.color = Gears.color(Theme.battery_normal_color)
            end
        end
    end)

    return widget
end

return module
