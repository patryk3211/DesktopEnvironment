local config = require("config")
local utility = require("utility")

local module = {}

function module.make()
    local widget = Wibox.layout.fixed.horizontal(
        Wibox.container.margin(Wibox.widget.textclock("%H:%M %d.%m.%Y"), 8, 0, 0, 0),
        Wibox.container.margin(Wibox.widget.imagebox(utility.colorSvg(config.iconPath.."/calendar.svg", Theme.clock_fg)),
                                10, 10, 6, 6)
    )

    return widget
end

return module
