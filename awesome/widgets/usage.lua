local utility = require("utility")
local config = require("config")

local module = {}

function module.make()
    local cpuUsageText = Wibox.widget.textbox("0%")
    cpuUsageText.font = Theme.info_font

    local ramText = Wibox.widget.textbox("0.00 GB")
    ramText.font = Theme.info_font

    local previousJiffiesTotal = {}
    local previousJiffiesWork = {}
    Gears.timer({
        timeout = 1.5,
        autostart = true,
        single_shot = false,
        callback = function ()
            -- Update info text
            Awful.spawn.easy_async("cat /proc/stat", function (stdout, stderr, reason, code)
                local totalUsage = 0

                -- TODO: Get the core count correctly
                for i = 0, 7 do
                    local j1, j2, j3, j4, j5, j6, j7 = stdout:match("cpu"..i.."%s+(%d+)%s+(%d+)%s+(%d+)%s+(%d+)%s+(%d+)%s+(%d+)%s+(%d+)%s+")
                    if j1 == nil then break end

                    if previousJiffiesWork[i + 1] == nil then
                        previousJiffiesWork[i + 1] = 0
                        previousJiffiesTotal[i + 1] = 0
                    end

                    local nowJiffiesTotal = j1 + j2 + j3 + j4 + j5 + j6 + j7
                    local nowJiffiesWork = j1 + j2 + j3

                    local cpuUsage = (nowJiffiesWork - previousJiffiesWork[i + 1]) / (nowJiffiesTotal - previousJiffiesTotal[i + 1])
                    cpuUsage = cpuUsage * 100
                    totalUsage = totalUsage + cpuUsage

                    previousJiffiesTotal[i + 1] = nowJiffiesTotal
                    previousJiffiesWork[i + 1] = nowJiffiesWork
                end

                if totalUsage < 10 then
                    cpuUsageText.text = string.format("%.1f%%", totalUsage)
                else
                    cpuUsageText.text = string.format("%.0f%%", totalUsage)
                end
            end)

            Awful.spawn.easy_async("free -m", function (stdout, stderr, reason, code)
                local total, used, free = stdout:match("Mem:%s+(%d+)%s+(%d+)%s+(%d+)")

                local ramUsageGb = used / 1024

                if ramUsageGb < 10 then
                    ramText.text = string.format("%.2f GB", ramUsageGb)
                else
                    ramText.text = string.format("%.1f GB", ramUsageGb)
                end
            end)
        end
    })

    local widget = Wibox.layout {
        layout = Wibox.layout.fixed.horizontal,
        {
            layout = Wibox.layout.align.horizontal,
            Wibox.container.margin(Wibox.widget.imagebox(utility.colorSvg(config.iconPath.."/cpu.svg", Theme.cpu_color)),
                        4, 4, 6, 6),
            nil,
            Wibox.container.margin(cpuUsageText, 0, 4, 0, 1),

            forced_width = 64
        },
        {
            widget = Wibox.widget.separator,
            thickness = 0,
            forced_width = 4
        },
        {
            layout = Wibox.layout.align.horizontal,
            Wibox.container.margin(Wibox.widget.imagebox(utility.colorSvg(config.iconPath.."/memory.svg", Theme.ram_color)),
                                    4, 4, 6, 6),
            nil,
            Wibox.container.margin(ramText, 0, 8, 0, 1),

            forced_width = 88
        }
    }

    return widget
end

return module
