local config = require("config")
local ruled = require("ruled")

-- Client rules
ruled.client.connect_signal("request::rules", function ()
    ruled.client.append_rule {
        id = "global",
        rule = { },
        properties = {
            border_width = Theme.border_width,
            border_color = Theme.border_normal,

            focus     = Awful.client.focus.filter,
            raise     = true,
            screen    = Awful.screen.preferred,
            placement = Awful.placement.no_overlap + Awful.placement.no_offscreen
        }
    }

    ruled.client.append_rule {
        id = "browser_tag",
        rule_any = {
            class = { "firefox" }
        },
        properties = {
            screen = 1,
            tag = config.groups[4].groupName
        }
    }

    ruled.client.append_rule {
        id = "discord_tag",
        rule_any = {
            class = { "discord" }
        },
        properties = {
            screen = 1,
            tag = config.groups[6].groupName
        }
    }

    ruled.client.append_rule {
        id = "password_manager_tag",
        rule_any = {
            instance = { "keepassxc" }
        },
        properties = {
            screen = 1,
            tag = config.groups[7].groupName
        }
    }

    ruled.client.append_rule {
        id = "steam_tag",
        rule_any = {
            class = { "Steam" }
        },
        properties = {
            screen = 1,
            tag = config.groups[8].groupName
        }
    }
end)

-- Notification rules
ruled.notification.connect_signal('request::rules', function()
    ruled.notification.append_rule {
        rule = { },
        properties = {
            screen = Awful.screen.preferred
        }
    }
end)
