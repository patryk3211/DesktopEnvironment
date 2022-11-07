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
    widget.thickness = style.thickness

    function widget:fit(context, width, height)
        return self.thickness, height
    end

    function widget:draw(context, cr, width, height)
        local halfThick = self.thickness / 2

        cr:arc(halfThick, height - halfThick, halfThick, 0, math.pi)
        cr:line_to(0, halfThick)
        cr:arc(halfThick, halfThick, halfThick, math.pi, 0)
        cr:close_path()

        cr:set_source(Gears.color(widget.bg))
        cr:fill()

        local heightFilled = self.value * (height - self.thickness) + self.thickness
        local yOffset = height - heightFilled

        cr:arc(halfThick, height - halfThick, halfThick, 0, math.pi)
        cr:line_to(0, yOffset + halfThick)
        cr:arc(halfThick, yOffset + halfThick, halfThick, math.pi, 0)
        cr:close_path()

        cr:set_source(Gears.color(widget.fg))
        cr:fill()
    end

    function widget:handle_movement(size, position)
        -- Clamp the position
        position = math.min(math.max(position, 0), size)
        self.value = 1 - (position / size)

        self:emit_signal("widget::redraw_needed")
        callback(self.value)
    end

    widget:connect_signal("button::press", function (self, mouseX, mouseY, button, _, geo)
        if button ~= 1 then return end

        local deviceMatrix = geo.hierarchy:get_matrix_from_device()
        local height = geo.widget_height

        self:handle_movement(height, mouseY)

        local widgetGeo = geo.drawable.drawable:geometry()
        local matrix = deviceMatrix:translate(-widgetGeo.x, -widgetGeo.y)

        mousegrabber.run(function (mouse)
            if not mouse.buttons[1] then
                return false
            end

            local wX, wY = matrix:transform_point(mouse.x, mouse.y)
            self:handle_movement(height, wY)

            return true
        end, "arrow")
    end)

    return widget
end

return module
