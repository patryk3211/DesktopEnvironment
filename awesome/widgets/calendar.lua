local config = require("config")
local utility = require("utility")

local module = {}

function module.makeClock()
    local widget = Wibox.layout.fixed.horizontal(
        Wibox.container.margin(Wibox.widget.textclock("%H:%M %d.%m.%Y"), 8, 0, 0, 0),
        Wibox.container.margin(Wibox.widget.imagebox(utility.colorSvg(config.iconPath.."/calendar.svg", Theme.clock_fg)),
                                10, 10, 6, 6)
    )

    local calendarPopup = Awful.popup {
        widget = {
            widget = Wibox.container.background,
            bg = "#000000",
            forced_width = 280,
            {
                layout = Wibox.layout.fixed.vertical,
                {
                    layout = Wibox.layout.align.horizontal,
                    {
                        widget = Wibox.widget.textbox,
                        text = "Calendar"
                    },
                    nil,
                    {
                        widget = Wibox.container.place,
                        forced_height = 24,
                        {
                            widget = Wibox.widget.imagebox,
                            image = Theme.getIcon("close", "#ffffff")
                        }
                    }
                },
                {
                    widget = Wibox.container.margin,
                    top = 5,
                    bottom = 5,
                    left = 5,
                    right = 5,

                    module.makeCalendar()
                }
            }
        },
        visible = false,
        ontop = true,
        placement = Awful.placement.next_to,
        preferred_position = "bottom",
        preferred_anchor = "front"
    }

    widget:buttons({
        Awful.button({}, 1, function ()
            calendarPopup.visible = true
            calendarPopup:move_next_to(widget)
        end)
    })

    return widget
end

function module.makeCalendar()
    local widget = Wibox.widget {
        widget = Wibox.widget.calendar.month,
        date = os.date("*t")
    }

    return widget
end

return module
