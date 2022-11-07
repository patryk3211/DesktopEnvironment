local naughty = require("naughty")

client.connect_signal("manage", function (c)
    -- Do not maximize windows by default
    c.maximized = false

    -- Prevent windows from getting placed off-screen
    if awesome.startup and not c.size_hints.user_position and not c.size_hints.program_position then
        Awful.placement.no_offscreen(c)
    end

    -- Spawn dialog windows on the center
    if c.type == "dialog" then
        Awful.placement.centered(c)
    end
end)

client.connect_signal("focus", function (c)
    c.border_color = Theme.border_focus
end)
client.connect_signal("unfocus", function (c)
    c.border_color = Theme.border_normal
end)

naughty.connect_signal("request::display", function(n)
    naughty.layout.box { notification = n }
end)
