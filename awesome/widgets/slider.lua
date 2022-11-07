local utility = require("utility")

local module = {}

function module.make(callback, value, style)
    local bg = Wibox.container.background(Wibox.widget.textbox(), style.color)
    bg.shape = Gears.shape.rounded_rect

    local slider = Wibox.widget {
        widget = Wibox.widget.slider,
        bar_color = "transparent",
        handle_shape = Gears.shape.circle,
        handle_color = style.color,
        handle_width = 8,

        minimum = 0,
        maximum = 100,
        value = value
    }

    local layout = Wibox.widget {
        layout = Wibox.layout.stack,
        {
            widget = Wibox.container.background,
            bg = style.background,
            shape = Gears.shape.rounded_rect,

            Wibox.widget.textbox()
        },
        slider,
        bg
    }

    local fraction = value / 100
    slider:connect_signal("property::value", function (obj)
        fraction = obj.value / 100
        callback(slider, fraction)
    end)

    bg._draw = bg.draw
    bg.draw = function (self, context, cr, width, height)
        self._draw(self, context, cr, math.min(width * fraction + 8, width), height)
    end

    slider.setColor = function (color)
        bg.bg = color
        slider.handle_color = color
    end

    slider.setValue = function (new_value)
        slider.value = new_value * 100
        fraction = new_value
    end

    return layout, slider
end

function module.makeVertical(callback, value, style)
    local widget = Wibox.widget.base.make_widget()
    widget.value = value
    widget.bg = style.background
    widget.fg = style.color

    function widget:fit(context, width, height)
        return 8, height
    end

    function widget:draw(context, cr, width, height)
        cr:arc(4, height - 4, 4, 0, math.pi)
        cr:line_to(0, 4)
        cr:arc(4, 4, 4, math.pi, 0)
        cr:close_path()

        cr:set_source(Gears.color(widget.bg))
        cr:fill()

        local heightFilled = self.value * height
        local yOffset = height - heightFilled

        cr:arc(4, height - 4, 4, 0, math.pi)
        cr:line_to(0, yOffset + 4)
        cr:arc(4, yOffset + 4, 4, math.pi, 0)
        cr:close_path()

        cr:set_source(Gears.color(widget.fg))
        cr:fill()
    end

    widget:connect_signal("button::press", function (self, mouseX, mouseY, button)
        utility.notifyInfo("Press", tostring(button))
    end)

    return widget
end

return module
