local slider = require("widgets.slider")

local module = {}

function module.make()
    local sliderContainer, sliderObject = slider.makeVertical(function ()
        -- Value changed
    end, 0.5, { color = "#0000ff", background = "#000000" })

    local widget = Wibox.widget {
        layout = Wibox.layout.fixed.vertical,
        sliderContainer
    }

    return widget
end

return module
