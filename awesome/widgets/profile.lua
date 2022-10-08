local utility = require "utility"
local module = {}

function module.make()
    local profile_picture = Wibox.widget {
        widget = Wibox.widget.imagebox,
        image = Theme.profile_picture
    }

    local username = Wibox.widget {
        widget = Wibox.widget.textbox,
        align = "center",
        font = "Hack Nerd Regular 20",
        text = "<user>"
    }

    local hostname = Wibox.widget {
        widget = Wibox.widget.textbox,
        align = "center",
        text = "<hostname>"
    }

    local layout = Wibox.widget {
        widget = Wibox.container.place,
        {
            layout = Wibox.layout.fixed.vertical,
            fill_space = true,
            {
                widget = Wibox.container.margin,
                bottom = 16,

                {
                    widget = Wibox.container.place,
                    profile_picture
                }
            },
            {
                widget = Wibox.container.place,
                {
                    layout = Wibox.layout.fixed.vertical,
                    {
                        widget = Wibox.container.background,
                        fg = Theme.mm_profile_username_color,
                        username
                    },
                    {
                        widget = Wibox.container.background,
                        fg = Theme.mm_profile_hostname_color,
                        hostname
                    }
                }
            }
        }
    }

    profile_picture.fit = function (self, context, width, height)
        local d = width * 0.9
        return d, d
    end

    Awful.spawn.easy_async("hostname", function (stdout, stderr, reason, code)
        hostname.text = stdout:sub(1, -2)
        if code ~= 0 then
            hostname.text = "Failed to retrieve hostname"
        end
    end)
    Awful.spawn.easy_async("sh -c 'getent passwd $(id -un) | cut -d \':\' -f 5'", function (stdout, stderr, reason, code)
        username.text = stdout:sub(1, -2)
        if code ~= 0 then
            username.text = "Failed to retrieve user name"
        end
    end)

    return layout
end

return module
