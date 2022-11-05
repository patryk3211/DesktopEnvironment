local keys = require("keybind")
local config = require("config")

local module = {}

function module.makeRules()
    Awful.rules.rules = {
        { -- Default rule
            rule = { },
            properties = {
                border_width = Theme.border_width,
                border_color = Theme.border_normal,
                focus = Awful.client.focus.filter,
                raise = true,
                keys = keys.clientKeys,
                buttons = keys.clientButtons,
                screen = Awful.screen.preferred,
                placement = Awful.placement.no_overlap+Awful.placement.no_offscreen
            }
        },
        { -- Force firefox on tag 2
            rule = { class = "firefox" },
            properties = {
                screen = 1,
                tag = config.groups[2].groupName
            }
        },
        { -- Force discord on tag 3
            rule = { class = "discord" },
            properties = {
                screen = 1,
                tag = config.groups[3].groupName
            }
        },
        {
            rule = { instance = "keepassxc" },
            properties = {
                screen = 1,
                tag = config.groups[4].groupName
            }
        }
    }
end

return module