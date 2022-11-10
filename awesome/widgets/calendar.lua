local config = require("config")
local utility = require("utility")

local module = {}

function module.makeClock()
    local widget = Wibox.layout.fixed.horizontal(
        Wibox.container.margin(Wibox.widget.textclock("%H:%M %d.%m.%Y"), 8, 0, 0, 0),
        Wibox.container.margin(Wibox.widget.imagebox(utility.colorSvg(config.iconPath.."/calendar.svg", Theme.clock_fg)),
                                10, 10, 6, 6)
    )

    local closeButton = Wibox.widget {
        widget = Wibox.container.background,
        {
            widget = Wibox.container.constraint,
            height = 24,
            strategy = "exact",
            {
                widget = Wibox.container.margin,
                top = 2,
                bottom = 2,
                left = 4,
                right = 4,

                Wibox.widget.imagebox(Theme.getIcon("close", "#ffffff"))
            }
        }
    }

    utility.smoothHoverColor(closeButton, Theme.calendar_header_bg, Theme.calendar_close_hover_color)

    local calendarPopup = Awful.popup {
        widget = {
            widget = Wibox.container.background,
            bg = Theme.calendar_bg,
            {
                layout = Wibox.layout.fixed.vertical,
                {
                    widget = Wibox.container.background,
                    bg = Theme.calendar_header_bg,
                    fg = Theme.calendar_header_fg,
                    {
                        layout = Wibox.layout.align.horizontal,
                        {
                            widget = Wibox.container.margin,
                            left = 5,
                            {
                                widget = Wibox.widget.textbox,
                                text = "Calendar"
                            }
                        },
                        nil,
                        closeButton
                    }
                },
                {
                    widget = Wibox.container.margin,
                    top = 4,
                    bottom = 4,
                    left = 8,
                    right = 8,

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
            if calendarPopup.visible then
                calendarPopup.visible = false
            else
                calendarPopup:move_next_to(widget)
            end
        end)
    })

    closeButton:buttons({
        Awful.button({}, 1, function ()
            calendarPopup.visible = false
        end)
    })

    return widget
end

local calendarStyles = nil

function module.makeCalendar()
    if not calendarStyles then
        calendarStyles = {
            header = {
                fg = Theme.calendar_month_fg
            },
            weekday = {
                fg = Theme.calendar_names_weekdays_fg
            },
            focus = {
                fg = Theme.calendar_today_fg
            },
            normal = {
                fg = Theme.calendar_days_fg
            }
        }
    end

    local widget = Wibox.widget {
        widget = Wibox.widget.calendar.month,
        date = os.date("*t"),
        long_weekdays = true,
        fn_embed = function (widget, flag, date)
            if flag == "monthheader" or flag == "month" then
                flag = "header"
            end

            local style = calendarStyles[flag]
            if style == nil then
                utility.notifyInfo("Nil calendar style", flag)
                return widget
            end

            return Wibox.widget {
                widget = Wibox.container.background,
                fg = style.fg,

                widget
            }
        end
    }

    return widget
end

return module
