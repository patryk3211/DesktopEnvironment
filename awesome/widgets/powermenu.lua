local utility = require("utility")
local rubato = require("rubato")
local easing = require("easing")

local module = {}

module.buttons = {
    { -- I might want the power actions to require a confirmation
        icon = "poweroff",
        func = function ()
            Awful.spawn("systemctl poweroff")
        end
    },
    {
        icon = "reboot",
        func = function ()
            Awful.spawn("systemctl reboot")
        end
    },
    {
        icon = "lock",
        func = function ()
            module.hideMenuFunc()
            Awful.spawn.with_shell("sleep 1; loginctl lock-session $XDG_SESSION_ID")
        end
    },
    {
        icon = "logout",
        func = function ()
            for _, c in ipairs(client.get()) do
                -- Close all windows gracefully
                c:kill()
            end
            Awful.spawn.with_shell("loginctl kill-session $XDG_SESSION_ID")
        end
    },
    {
        icon = "sleep",
        func = function ()
            module.hideMenuFunc()
            Awful.spawn("systemctl suspend")
        end
    }
}

function module.make(hideMenuFunc, orientation)
    module.hideMenuFunc = hideMenuFunc

    local widget = nil
    if not orientation or orientation == "vertical" then
        widget = Wibox.widget {
            layout = Wibox.layout.grid,
            homogeneous = true,
            spacing = 10,
            orientation = "vertical",
            forced_num_cols = 1
        }
    elseif orientation == "horizontal" then
        widget = Wibox.widget {
            layout = Wibox.layout.grid,
            homogeneous = true,
            spacing = 10,
            orientation = "horizontal",
            forced_num_rows = 1
        }
    else
        error("Unknown orientation specified, '"..tostring(orientation).."'", 1)
    end

    for i, b in ipairs(module.buttons) do
        local img = Wibox.widget.imagebox(Theme.getIcon(b.icon, Theme.mm_powermenu_icon_colors[i]))

        local button = Wibox.widget {
            widget = Wibox.container.background,
            bg = Theme.mm_powermenu_bg,
            shape = Gears.shape.rounded_rect,

            {
                widget = Wibox.container.margin,
                top = 16,
                bottom = 16,
                right = 16,
                left = 16,

                img
            },

            buttons = Gears.table.join(
                Awful.button({}, 1, b.func)
            )
        }

        utility.smoothHoverColor(button, Theme.mm_powermenu_bg, Theme.mm_powermenu_bg_hover)

        widget:add(button)
    end

    return widget
end

return module
