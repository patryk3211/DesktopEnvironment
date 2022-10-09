local utility = require("utility")

local module = {}

local function makeSlider(callback, value)
    local bg = Wibox.container.background(Wibox.widget.textbox(), Theme.mm_sound_slider_color)
    bg.shape = Gears.shape.rounded_rect

    local slider = Wibox.widget {
        widget = Wibox.widget.slider,
        bar_color = "transparent",
        handle_shape = Gears.shape.circle,
        handle_color = Theme.mm_sound_slider_color,
        handle_width = 8,

        minimum = 0,
        maximum = 100,
        value = value
    }

    local layout = Wibox.widget {
        layout = Wibox.layout.stack,
        {
            widget = Wibox.container.background,
            bg = Theme.mm_sound_slider_bg,
            shape = Gears.shape.rounded_rect,

            Wibox.widget.textbox()
        },
        slider,
        bg
    }

    local fraction = value / 100
    slider:connect_signal("property::value", function (obj)
        fraction = obj.value / 100
        callback(slider, fraction)
    end)

    bg._draw = bg.draw
    bg.draw = function (self, context, cr, width, height)
        self._draw(self, context, cr, math.min(width * fraction + 8, width), height)
    end

    slider.setColor = function (color)
        bg.bg = color
        slider.handle_color = color
    end

    slider.setValue = function (new_value)
        slider.value = new_value * 100
        fraction = new_value
    end

    return layout, slider
end

local function makeBar(icon, callback, value)
    if value == nil then
        value = 1
    end
    local multipliedValue = math.floor(value * 100)

    local text = Wibox.widget.textbox(tostring(multipliedValue).."%")
    text.forced_width = 40

    local widget, slider = makeSlider(function (slider, value)
        text.text = tostring(math.floor(value * 100)).."%"
        callback(slider, value)
    end, multipliedValue)

    local layout = Wibox.widget {
        layout = Wibox.layout.align.horizontal,
        forced_height = 22,

        Wibox.widget.imagebox(Theme.getIcon(icon, Theme.mm_sound_icon_color)),
        {
            widget = Wibox.container.margin,
            top = 7,
            bottom = 7,
            left = 8,
            right = 8,

            widget
        },
        {
            widget = Wibox.container.margin,
            top = 4,
            bottom = 4,
            left = 6,
            right = 6,

            text
        }
    }
    layout.slider = slider

    return layout
end

function module.make(audioInfoCallback)
    local widget = Wibox.widget {
        layout = Wibox.layout.fixed.vertical,
        spacing = 12,

        Wibox.widget.textbox("Retrieving audio information...")
    }

    local makeMenu = coroutine.create(function ()
        coroutine.yield() -- Advance in code on second execution

        widget:remove(1)

        local bars = {
            makeBar("speaker", function (slider, value)
                if not widget.speakerState then
                    slider.setValue(slider.savedVolume)
                else
                    widget.speakerVolume = value
                    Awful.spawn("amixer -D pulse set Master "..tostring(value * 100).."%")
                end
            end, widget.speakerVolume),
            makeBar("microphone", function (slider, value)
                if not widget.microphoneState then
                    slider.setValue(slider.savedVolume)
                else
                    widget.microphoneVolume = value
                    Awful.spawn("amixer -D pulse set Capture "..tostring(value * 100).."%")
                end
            end, widget.microphoneVolume)
        }

        local names = {
            "Master Playback",
            "Master Capture"
        }

        for i, bar in ipairs(bars) do
            local entry = Wibox.widget {
                layout = Wibox.layout.fixed.vertical,
                spacing = 6,

                Wibox.widget.textbox(names[i]),
                bar
            }
            widget:add(entry)
        end

        widget.setMute = function (barId, state)
            local color = Theme.mm_sound_slider_color_muted
            local strState = "mute"
            if not state then
                color = Theme.mm_sound_slider_color
                strState = "unmute"
            end
            bars[barId].slider.setColor(color)
            bars[barId].slider.savedVolume = bars[barId].slider.value / 100
            if barId == 1 then
                Awful.spawn("amixer -D pulse set Master "..strState)
                widget.speakerState = not state
            elseif barId == 2 then
                Awful.spawn("amixer -D pulse set Capture "..strState)
                widget.microphoneState = not state
            end
        end

        widget.updateBars = function ()
            bars[1].slider.setValue(widget.speakerVolume)
            bars[2].slider.setValue(widget.microphoneVolume)
        end

        audioInfoCallback({
            { volume = widget.speakerVolume, state = widget.speakerState },
            { volume = widget.microphoneVolume, state = widget.microphoneState }
        })
    end)

    Awful.spawn.easy_async("amixer -D pulse get Master", function (stdout, stderr, code, reason)
        local percent, state = stdout:match("Playback%s+%d+%s+%[(%d+)%%%]%s+%[(%w+)%]")
        widget.speakerVolume = percent / 100
        if state == "on" then
            widget.speakerState = true
        else
            widget.speakerState = false
        end
        coroutine.resume(makeMenu)
    end)

    Awful.spawn.easy_async("amixer -D pulse get Capture", function (stdout, stderr, code, reason)
        local percent, state = stdout:match("Capture%s+%d+%s+%[(%d+)%%%]%s+%[(%w+)%]")
        widget.microphoneVolume = percent / 100
        if state == "on" then
            widget.microphoneState = true
        else
            widget.microphoneState = false
        end
        coroutine.resume(makeMenu)
    end)

    return widget
end

return module
