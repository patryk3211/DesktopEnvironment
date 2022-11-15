local config = require("config")
local utility = require("utility")

local module = {}

function module.makeClock()
    local widget = Wibox.layout.fixed.horizontal(
        Wibox.container.margin(Wibox.widget.textclock("%H:%M %d.%m.%Y"), 8, 0, 0, 0),
        Wibox.container.margin(Wibox.widget.imagebox(utility.colorSvg(config.iconPath.."/calendar.svg", Theme.clock_fg)),
                                10, 10, 6, 6)
    )

    local calendar = module.makeCalendar()
    local currentDate

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

    local leftButton = Wibox.widget {
        widget = Wibox.container.background,
        {
            widget = Wibox.container.constraint,
            strategy = "exact",
            width = 20,
            {
                widget = Wibox.container.place,
                valign = "center",
                halign = "center",
                {
                    widget = Wibox.widget.imagebox,
                    image = Theme.getIcon("arrow-left", "#ffffff")
                }
            }
        }
    }

    leftButton:buttons({
        Awful.button({}, 1, function ()
            -- Go to previous month
            local newDate = { month = calendar.date.month - 1, year = calendar.date.year }
            if newDate.month < 1 then
                newDate.month = 12
                newDate.year = newDate.year - 1
            end

            if newDate.month == currentDate.month and newDate.year == currentDate.year then
                newDate.day = currentDate.day
            end
            calendar.date = newDate
        end)
    })

    local rightButton = Wibox.widget {
        widget = Wibox.container.background,
        {
            widget = Wibox.container.constraint,
            strategy = "exact",
            width = 20,
            {
                widget = Wibox.container.place,
                valign = "center",
                halign = "center",
                {
                    widget = Wibox.widget.imagebox,
                    image = Theme.getIcon("arrow-right", "#ffffff")
                }
            }
        }
    }

    rightButton:buttons({
        Awful.button({}, 1, function ()
            -- Go to next month
            local newDate = { month = calendar.date.month + 1, year = calendar.date.year }
            if newDate.month > 12 then
                newDate.month = 1
                newDate.year = newDate.year + 1
            end

            if newDate.month == currentDate.month and newDate.year == currentDate.year then
                newDate.day = currentDate.day
            end
            calendar.date = newDate
        end)
    })

    utility.smoothHoverColor(leftButton, Theme.calendar_bg, Theme.calendar_button_hover)
    utility.smoothHoverColor(rightButton, Theme.calendar_bg, Theme.calendar_button_hover)

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
                    layout = Wibox.layout.fixed.horizontal,
                    leftButton,
                    {
                        widget = Wibox.container.margin,
                        top = 4,
                        bottom = 4,
                        left = 8,
                        right = 8,

                        calendar
                    },
                    rightButton
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
                calendarPopup.placement = Awful.placement.next_to
            else
                calendarPopup:move_next_to(widget)
                local date = os.date("*t")
                calendar.date = { year = date.year, month = date.month, day = date.day }
                currentDate = calendar.date
                calendarPopup.placement = nil
            end
        end)
    })

    closeButton:buttons({
        Awful.button({}, 1, function ()
            calendarPopup.visible = false
            calendarPopup.placement = Awful.placement.next_to
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

function module.makeCompactClock()
    local widget = Wibox.widget {
        widget = Wibox.widget.textclock,
        format = "<b>%H:%M</b>\n%a %d, %b %Y",
        halign = "center"
    }
    return widget
end

return module
