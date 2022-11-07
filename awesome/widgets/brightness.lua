local slider = require("widgets.slider")
local utility= require("utility")

local module = {}

function module.make()
    local sliderObject = slider.makeVertical(function (value)
        -- Value changed
        Awful.spawn(string.format("brightnessctl set %d", math.floor(value * 100)))
    end, 0, { color = Theme.mm_brightness_slider_color, background = Theme.mm_brightness_slider_bg, thickness = 10 })

    -- Get initial slider value
    Awful.spawn.easy_async("brightnessctl get", function (stdout)
        sliderObject.value = tonumber(stdout) / 100
        sliderObject:emit_signal("widget::redraw_needed")
    end)

    local widget = Wibox.widget {
        layout = Wibox.layout.ratio.vertical,
        {
            widget = Wibox.container.place,
            halign = "center",
            sliderObject
        },
        {
            widget = Wibox.container.margin,
            top = 10,
            left = 8,
            right = 8,
            {
                widget = Wibox.container.place,
                halign = "center",
                valign = "center",
                {
                    widget = Wibox.widget.imagebox,
                    image = Theme.getIcon("brightness", Theme.mm_brightness_icon_color)
                }
            }
        }
    }

    widget:adjust_ratio(2, 0.825, 0.175, 0)

    return widget
end

return module
