local naughty = require("naughty")
local rubato = require("rubato")
local easing = require("easing")

local module = {}

local svgCache = {}

function module.notifyInfo(title, text)
    naughty.notify({
        preset = naughty.config.presets.info,
        title = title,
        text = text
    })
end

--- Sets the wallpaper on screen from theme's wallpaper parameter
---@param screen unknown
function module.resetWallpaper(screen)
    if Theme.wallpaper then
        Gears.wallpaper.maximized(Theme.wallpaper, screen, true)
    end
end

--- Changes the color of an image and stores it in cache
---@param svg string Path to an image
---@param color string Color in the hex format
---@return unknown
function module.colorSvg(svg, color)
    local id = svg..color
    local cacheEntry = svgCache[id]
    if cacheEntry then return cacheEntry end

    cacheEntry = Gears.color.recolor_image(svg, color)
    svgCache[id] = cacheEntry
    return cacheEntry
end

--- Returns the first dbus destination for a specified prefix
---@param prefix string
---@param callback function
function module.getDbusTarget(prefix, callback)
    Awful.spawn.easy_async("qdbus", function (stdout, stderr, reason, code)
        local mpStart = stdout:find(prefix)
        if mpStart == nil then
            return
        end

        local lineEnd = stdout:find("\n", mpStart)
        if lineEnd == nil then
            lineEnd = stdout:len()
        else
            lineEnd = lineEnd - 1
        end

        callback(stdout:sub(mpStart, lineEnd))
    end)
end

--- Spawns the process only if it is not already running on this user
---@param cmd string
function module.spawnOne(cmd)
    local separator = cmd:find(" ")
    local exec = cmd
    if separator then
        exec = cmd:sub(0, separator - 1)
    end

    Awful.spawn.easy_async("sh -c 'pgrep -i -u $(id -u) "..exec.."'", function (stdout, stderr, reason, code)
        if code ~= 0 then
            Awful.spawn(cmd)
        end
    end)
end

function module.mixColor(c1, c2, mix)
    local inv = 1 - mix
    local color = { c1[1] * inv + c2[1] * mix,
                    c1[2] * inv + c2[2] * mix,
                    c1[3] * inv + c2[3] * mix,
                    c1[4] * inv + c2[4] * mix }
    return color
end

function module.mixColorHtml(c1, c2, mix)
    local inv = 1 - mix
    local c1s = table.pack(c1:match("#(%x%x)(%x%x)(%x%x)(%x?%x?)"))
    local c2s = table.pack(c2:match("#(%x%x)(%x%x)(%x%x)(%x?%x?)"))

    local function number(array)
        local result = {}
        for i, v in ipairs(array) do
            if v == "" then
                result[i] = nil
            else
                result[i] = tonumber(v, 16)
            end
        end
        return result
    end

    local c1n = number(c1s)
    local c2n = number(c2s)

    if c1n[4] == nil then
        c1n[4] = 255
    end
    if c2n[4] == nil then
        c2n[4] = 255
    end

    local result = {}
    for i = 1, 4 do
        result[i] = math.floor(c1n[i] * inv + c2n[i] * mix)
        if result[i] ~= result[i] then
            result[i] = 0
        end
    end

    return string.format("#%02x%02x%02x%02x", result[1], result[2], result[3], result[4])
end

local lookup = "0123456789abcdef"
function module.makeHtmlColor(color)
    local output = "#"

    local function convertPart(value)
        local byteVal = math.floor(value * 255)

        local c1 = (byteVal & 0xF) + 1
        local c2 = (byteVal >> 4) + 1

        output = output..lookup:sub(c2, c2)..lookup:sub(c1, c1)
    end

    convertPart(color[1])
    convertPart(color[2])
    convertPart(color[3])
    convertPart(color[4])

    return output
end

function module.hoverColor(object, normal, hover)
    object:connect_signal("mouse::enter", function ()
        object.bg = hover
    end)
    object:connect_signal("mouse::leave", function ()
        object.bg = normal
    end)
end

function module.smoothHoverColor(object, normal, hover)
    local timer = rubato.timed {
        duration = 1/6,
        intro = 0,
        easing = easing.easeinout
    }
    timer:subscribe(function (pos)
        if pos ~= pos then
            timer.pos = 0
            pos = 0
        end

        object.bg = module.mixColorHtml(normal, hover, pos)
    end)

    object:connect_signal("mouse::enter", function ()
        timer.target = 1
    end)
    object:connect_signal("mouse::leave", function ()
        timer.target = 0
    end)
end

function module.smoothHoverColorCallback(object, normalColorProvider, hoverColorProvider)
    local timer = rubato.timed {
        duration = 1/6,
        intro = 0,
        easing = easing.easeinout
    }
    timer:subscribe(function (pos)
        if pos ~= pos then
            timer.pos = 0
            pos = 0
        end

        object.bg = module.mixColorHtml(normalColorProvider(), hoverColorProvider(), pos)
    end)

    object:connect_signal("mouse::enter", function ()
        timer.target = 1
    end)
    object:connect_signal("mouse::leave", function ()
        timer.target = 0
    end)
end

local lastUsage = 0
function module.memoryUsage()
    local nowUsage = collectgarbage("count")
    module.notifyInfo("Memory Usage", tostring(nowUsage - lastUsage))
    lastUsage = nowUsage
end

return module
