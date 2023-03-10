local utility = require("utility")
local sliderWidget = require("widgets.slider")

local module = {}

local function makeBar(icon, callback, value)
    if value == nil then
        value = 1
    end
    local multipliedValue = math.floor(value * 100)

    local text = Wibox.widget.textbox(tostring(multipliedValue).."%")
    text.forced_width = 40

    local slider = sliderWidget.makeHorizontal(function (value, slider)
        text.text = tostring(math.floor(value * 100)).."%"
        callback(slider, value)
    end, value, { color = Theme.mm_sound_slider_color, background = Theme.mm_sound_slider_bg, thickness = 8 })

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

            slider
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
                    slider.set_value(slider.savedVolume)
                else
                    widget.speakerVolume = value
                    Awful.spawn(string.format("amixer -D pulse set Master %d%%", math.floor(value * 100)))
                end
            end, widget.speakerVolume),
            makeBar("microphone", function (slider, value)
                if not widget.microphoneState then
                    slider.set_value(slider.savedVolume)
                else
                    widget.microphoneVolume = value
                    Awful.spawn(string.format("amixer -D pulse set Capture %d%%", math.floor(value * 100)))
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
            bars[barId].slider.savedVolume = bars[barId].slider.value
            if barId == 1 then
                local strState = "mute"
                if not state then
                    color = Theme.mm_sound_slider_color
                    strState = "unmute"
                end
                Awful.spawn("amixer -D pulse set Master "..strState)
                widget.speakerState = not state
            elseif barId == 2 then
                local strState = "nocap"
                if not state then
                    color = Theme.mm_sound_slider_color
                    strState = "cap"
                end
                Awful.spawn("amixer -D pulse set Capture "..strState)
                widget.microphoneState = not state
            end
            bars[barId].slider.fg = color
        end

        widget.updateBars = function ()
            bars[1].slider.set_value(widget.speakerVolume)
            bars[2].slider.set_value(widget.microphoneVolume)
        end

        audioInfoCallback({
            { volume = widget.speakerVolume, state = widget.speakerState },
            { volume = widget.microphoneVolume, state = widget.microphoneState }
        })
    end)

    Gears.timer {
        timeout = 1,
        autostart = true,
        single_shot = true,
        callback = function ()
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
        end
    }

    return widget
end

return module
