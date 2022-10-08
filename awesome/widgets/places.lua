local config = require("config")
local utility = require("utility")

local module = {}

local function makeText(text, path, openLocationCallback)
    local widget = Wibox.widget {
        widget = Wibox.container.background,
        {
            widget = Wibox.container.margin,
            top = 5,
            bottom = 5,
            left = 5,
            right = 5,
            {
                widget = Wibox.widget.textbox,
                align = "center",
                markup = "<span size = '14pt'>"..text.."</span>"
            }
        }
    }

    utility.smoothHoverColor(widget, Theme.mm_places_entry_color, Theme.mm_places_entry_hover_color)

    widget:buttons(Gears.table.join(
        Awful.button({}, 1, function ()
            openLocationCallback(path)
        end)
    ))

    return widget
end

function module.make(openLocationCallback)
    local widget = Wibox.widget {
        layout = Wibox.layout.fixed.vertical,

        {
            widget = Wibox.container.background,
            fg = Theme.mm_places_header_color,

            {
                widget = Wibox.widget.textbox,
                align = "center",
                markup = "<span size='20pt' weight='600'>Places</span>"
            }
        }
    }

    for i, entry in ipairs(config.places) do
        widget:add(makeText(entry.name, entry.path, openLocationCallback))
    end

    local colorCount = #Theme.mm_places_text_colors
    for i = 0, #widget.children - 2 do
        widget.children[i + 2].fg = Theme.mm_places_text_colors[(i % colorCount) + 1]
    end

    return widget
end

return module
