local utility = require("utility")

local module = {}

function module.makeHorizontal(callback, value, style)
    local widget = Wibox.widget.base.make_widget()
    widget.value = value
    widget.bg = style.background
    widget.fg = style.color
    widget.thickness = style.thickness

    function widget:fit(context, width, height)
        return width, self.thickness
    end

    function widget:draw(context, cr, width, height)
        local halfThick = self.thickness / 2

        cr:arc(width - halfThick, halfThick, halfThick, math.pi / 2 * 3, math.pi / 2)
        cr:arc(halfThick, halfThick, halfThick, math.pi / 2, math.pi / 2 * 3)
        cr:close_path()

        cr:set_source(Gears.color(widget.bg))
        cr:fill()

        local widthFilled = self.value * (width - self.thickness) + self.thickness

        cr:arc(halfThick, halfThick, halfThick, math.pi / 2, math.pi / 2 * 3)
        cr:arc(widthFilled - halfThick, halfThick, halfThick, math.pi / 2 * 3, math.pi / 2)
        cr:close_path()

        cr:set_source(Gears.color(widget.fg))
        cr:fill()
    end

    function widget:handle_movement(size, position)
        -- Clamp the position
        position = math.min(math.max(position, 0), size)
        self.value = (position / size)

        self:emit_signal("widget::redraw_needed")
        callback(self.value, self)
    end

    widget:connect_signal("button::press", function (self, mouseX, mouseY, button, _, geo)
        if button ~= 1 then return end

        local deviceMatrix = geo.hierarchy:get_matrix_from_device()
        local width = geo.widget_width

        self:handle_movement(width, mouseX)

        local widgetGeo = geo.drawable.drawable:geometry()
        local matrix = deviceMatrix:translate(-widgetGeo.x, -widgetGeo.y)

        mousegrabber.run(function (mouse)
            if not mouse.buttons[1] then
                return false
            end

            local wX, wY = matrix:transform_point(mouse.x, mouse.y)
            self:handle_movement(width, wX)

            return true
        end, "arrow")
    end)

    function widget:set_value(value)
        self.value = value
        self:emit_signal("widget::redraw_needed")
    end

    return widget
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

    function widget:set_value(value)
        self.value = value
        self:emit_signal("widget::redraw_needed")
    end

    return widget
end

return module
